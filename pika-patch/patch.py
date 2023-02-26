from typing import Callable
import os
import math
import copy
from ndspy.rom import NintendoDSRom

from skytemple_files.common.ppmdu_config.data import Pmd2Data, GAME_VERSION_EOS, GAME_REGION_US, GAME_REGION_EU
from skytemple_files.patch.handler.abstract import AbstractPatchHandler
from skytemple_files.data.str.handler import StrHandler
from skytemple_files.common.util import *
from skytemple.core.string_provider import StringType
from skytemple_files.data.md.handler import MdHandler
from skytemple_files.graphics.kao.handler import KaoHandler
from skytemple_files.graphics.kao import SUBENTRIES
from skytemple.controller.main import MainController
from skytemple_files.graphics.kao.sprite_bot_sheet import SpriteBotSheet
from skytemple_files.graphics.chara_wan.handler import CharaWanHandler
from skytemple_files.container.bin_pack.model import BinPack
from skytemple_files.container.bin_pack.handler import BinPackHandler
from skytemple_files.common.types.file_types import FileType
from skytemple_files.hardcoded.monster_sprite_data_table import HardcodedMonsterSpriteDataTable
from skytemple_files.patch.patches import Patcher
from xml.etree import ElementTree
from zipfile import ZipFile


NUM_PREVIOUS_ENTRIES = 600
NUM_NEW_ENTRIES = 2048
US_NEW_PKMN_STR_REGION = 0x4814
US_NEW_CAT_STR_REGION = 0x5014
EU_NEW_PKMN_STR_REGION = 0x4833
EU_NEW_CAT_STR_REGION = 0x5033

LANG_NAME_ASOC = {
"MESSAGE/text_e.str": "names_e.txt",
"MESSAGE/text_f.str": "names_f.txt",
"MESSAGE/text_g.str": "names_g.txt",
"MESSAGE/text_i.str": "names_i.txt",
"MESSAGE/text_s.str": "names_s.txt",
}

LANG_CAT_ASOC = {
"MESSAGE/text_e.str": "cats_e.txt",
"MESSAGE/text_f.str": "cats_f.txt",
"MESSAGE/text_g.str": "cats_g.txt",
"MESSAGE/text_i.str": "cats_i.txt",
"MESSAGE/text_s.str": "cats_s.txt",
}

class PatchHandler(AbstractPatchHandler):

    @property
    def name(self) -> str:
        return 'PikaPatch'

    @property
    def description(self) -> str:
        return "You get a mew and you get a mew!, everyone gets a mew! ... But not you! You get a mewtwo!"

    @property
    def author(self) -> str:
        return 'Roka'

    @property
    def version(self) -> str:
        return '0.0.3'

    def is_applied(self, rom: NintendoDSRom, config: Pmd2Data) -> bool:
        return False;

    def apply(self, apply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        if config.game_region == GAME_REGION_US:
            new_pkmn_str_region = US_NEW_PKMN_STR_REGION
            new_cat_str_region = US_NEW_CAT_STR_REGION
        if config.game_region == GAME_REGION_EU:
            new_pkmn_str_region = EU_NEW_PKMN_STR_REGION
            new_cat_str_region = EU_NEW_CAT_STR_REGION

        # Get the location of our 'patch.py' because we need to load addional files from there!
        pwd = os.path.dirname(os.path.realpath(__file__))
        self._cur_rom = rom

        patcher = Patcher(rom, get_ppmdu_config_for_rom(rom))
        expanded_pokelist = False
        mon_count = NUM_PREVIOUS_ENTRIES
        if patcher.is_applied("ExpandPokeList"):
            print(f'Working with expanded pokemon list!')
            expanded_pokelist = True
            mon_count = NUM_NEW_ENTRIES

        print(f'Patching strings:')

        # Go over every text file in the rom
        for filename in get_files_from_rom_with_extension(rom, "str"):
            # Try to update text entrys
            try:
                # Load the original Text data from the rom
                bin_before = rom.getFileByName(filename)
                strings = StrHandler.deserialize(bin_before)

                if filename in LANG_NAME_ASOC:
                    # Look at what file to load to get our new names from
                    name_file = LANG_NAME_ASOC[filename]

                    if(os.path.exists(f'{pwd}/{name_file}')):
                        # Open the file and load the new names
                        name_data = open(f'{pwd}/{name_file}').read().splitlines()
                        print(f'    Trying to update {filename} with {name_file}')
                        # Look up where in the rom our Text data is
                        block = config.string_index_data.string_blocks["Pokemon Names"]
                        # get monster count we need this later
                        block_len = block.end - block.begin

                        # Do we have enough names?
                        if(mon_count > len(name_data)):
                            raise UserValueError(f'Expected {mon_count} entrys but "{name_file}" has only {len(name_data)}')

                        # Update our names
                        for x in range(mon_count):
                            if name_data[x] != "":
                                if expanded_pokelist:
                                    strings.strings[new_pkmn_str_region + x - 1] = name_data[x]
                                else:
                                    if x < block_len:
                                        strings.strings[x+block.begin] = name_data[x]

                if filename in LANG_CAT_ASOC:
                    # Look at what file to load to get our new categorys from
                    cat_file = LANG_CAT_ASOC[filename]


                    if(os.path.exists(f'{pwd}/{cat_file}')):
                        # Open the file and load the new categorys
                        cat_data = open(f'{pwd}/{cat_file}').read().splitlines()
                        print(f'Trying to update {filename} with {cat_file}')
                        # Look up where in the rom our Text data is
                        block = config.string_index_data.string_blocks["Pokemon Categories"]
                        # get monster count we need this later
                        block_len = block.end - block.begin

                        # Do we have enough categorys?
                        if(mon_count > len(cat_data)):
                            raise UserValueError(f'Expected {mon_count} entrys but "{cat_file}" has only {len(cat_data)}')

                        # Update our categorys
                        for x in range(mon_count):
                            if cat_data[x] != "":
                                if expanded_pokelist:
                                    strings.strings[new_cat_str_region + x - 1] = cat_data[x]
                                else:
                                    if x < block_len:
                                        strings.strings[x+block.begin] = cat_data[x]

                # Save our new text data
                bin_after = StrHandler.serialize(strings)
                rom.setFileByName(filename, bin_after)
            except:
                print(f'Could not update {filename} ...')
                raise

        print(f'Patching Portraits:')

        # Open the files and load the new portraits
        portg1_data = open(f'{pwd}/portraits_gender1.txt').read().splitlines()
        portg2_data = open(f'{pwd}/portraits_gender2.txt').read().splitlines()

        # Do we have enough portraits for gender1?
        if(mon_count > len(portg1_data)):
            raise UserValueError(f'Expected {mon_count} entrys but "portraits_gender1.txt" has only {len(portg1_data)}')

        # Do we have enough portraits for gender2?
        if(mon_count > len(portg2_data)):
            raise UserValueError(f'Expected {mon_count} entrys but "portraits_gender2.txt" has only {len(portg2_data)}')

        # Create fresh portrait data
        kao_model = KaoHandler.new(mon_count*2)

        # Go over the portraits of every monster
        for i in range(mon_count):
            # do we have an entry?
            if(portg1_data[i] != "NONE"):
                print(f'    Patching monster{i} gender1 portraits')
                # get the right sprite sheet for gender1

                g1_sheet = SpriteBotSheet.load(f'{pwd}/{portg1_data[i]}', self._get_portrait_name)
                # go over every portrait and set the new image
                for subindex, image in g1_sheet:
                    kao_model.set_from_img(i, subindex, image)

            # do we have an entry?
            if(portg2_data[i] != "NONE"):
                print(f'    Patching monster{i} gender2 portraits')
                # get the right sprite sheet for gender2

                g2_sheet = SpriteBotSheet.load(f'{pwd}/{portg2_data[i]}', self._get_portrait_name)
                # go over every portrait and set the new image
                for subindex, image in g2_sheet:
                    kao_model.set_from_img(i+mon_count, subindex, image)

        # Save our portrait data
        rom.setFileByName("FONT/kaomado.kao", KaoHandler.serialize(kao_model))

        print(f'Patching sprites:')

        spriteg1_data = open(f'{pwd}/sprites_gender1.txt').read().splitlines()
        spriteg2_data = open(f'{pwd}/sprites_gender2.txt').read().splitlines()

        # Do we have enough portraits for gender1?
        if(mon_count > len(spriteg1_data)):
            raise UserValueError(f'Expected {mon_count} entrys but "sprites_gender1.txt" has only {len(spriteg1_data)}')

        # Do we have enough portraits for gender2?
        if(mon_count > len(spriteg2_data)):
            raise UserValueError(f'Expected {mon_count} entrys but "sprites_gender2.txt" has only {len(spriteg2_data)}')

        sprite_sheets = {}

        mmb_bin = rom.getFileByName("MONSTER/monster.bin")
        mmb_model = BinPackHandler.deserialize(mmb_bin)
        self._monster_bin = mmb_model

        mgb_bin = rom.getFileByName("MONSTER/m_ground.bin")
        mgb_model = BinPackHandler.deserialize(mgb_bin)

        mab_bin = rom.getFileByName("MONSTER/m_attack.bin")
        mab_model = BinPackHandler.deserialize(mab_bin)

        md_bin = rom.getFileByName("BALANCE/monster.md")
        md_model = MdHandler.deserialize(md_bin)

        static_data = get_ppmdu_config_for_rom(rom)
        rom_sprite_table = HardcodedMonsterSpriteDataTable.get(rom.arm9, config)

        sprite_overwrite_index = 0

        for i in range(mon_count):
            # do we have an entry?
            if(spriteg1_data[i] != "NONE"):
                print(f'    Patching monster{i} gender1 sprites')
                if spriteg1_data[i] not in sprite_sheets:
                    print(f'        Loading new sprites "{spriteg1_data[i]}"')
                    wan = FileType.WAN.CHARA.import_sheets_from_zip(f'{pwd}/{spriteg1_data[i]}')
                    monster, ground, attack = FileType.WAN.CHARA.split_wan(wan)

                    ZipObj = ZipFile(f'{pwd}/{spriteg1_data[i]}', 'r')
                    tree = ElementTree.fromstring(ZipObj.read('AnimData.xml'))
                    sprite_sheets[spriteg1_data[i]] = [sprite_overwrite_index,int(tree.find('ShadowSize').text)]

                    mmb_bytes = FileType.WAN.CHARA.serialize(monster)
                    mmb_data = FileType.PKDPX.serialize(FileType.PKDPX.compress(mmb_bytes))
                    mmb_model[sprite_overwrite_index] = mmb_data

                    mgb_bytes = FileType.WAN.CHARA.serialize(ground)
                    mgb_model[sprite_overwrite_index] = mgb_bytes

                    mab_bytes = FileType.WAN.CHARA.serialize(attack)
                    mab_data = FileType.PKDPX.serialize(FileType.PKDPX.compress(mab_bytes))
                    mab_model[sprite_overwrite_index] = mab_data

                    sprite_overwrite_index = sprite_overwrite_index + 1

                sprite_index_g1 = sprite_sheets[spriteg1_data[i]]
                if i < len(md_model.entries):
                    md_model.entries[i].sprite_index = sprite_index_g1[0]
                    md_model.entries[i].shadow_size = sprite_index_g1[1]

                    tile_slots, file_size = self._get_sprite_properties(md_model.entries[i])
                    if expanded_pokelist:
                        md_model.entries[i].unk17 = tile_slots
                        md_model.entries[i].unk18 = file_size
                    else:
                        rom_sprite_table[i].sprite_tile_slots = max(tile_slots,rom_sprite_table[i].sprite_tile_slots);
                        rom_sprite_table[i].unk1 = max(file_size,rom_sprite_table[i].unk1)


            # do we have an entry?
            if spriteg2_data[i] != "NONE" :
                if expanded_pokelist:
                    print(f'    Patching monster{i} gender2 sprites')
                else:
                    if spriteg1_data[i] != spriteg2_data[i]:
                        print(f'    Patching monster{i} gender2 sprites. WARNING: You are trying to set different sprites for the genders without the "ExpandPokeList" patch. This should work as long as you have less then 600 different sprites in total.')
                    else:
                        print(f'    Patching monster{i} gender2 sprites.')

                if spriteg2_data[i] not in sprite_sheets:
                    print(f'        Loading new sprites "{spriteg2_data[i]}"')
                    wan = FileType.WAN.CHARA.import_sheets_from_zip(f'{pwd}/{spriteg2_data[i]}')
                    monster, ground, attack = FileType.WAN.CHARA.split_wan(wan)

                    ZipObj = ZipFile(f'{pwd}/{spriteg2_data[i]}', 'r')
                    tree = ElementTree.fromstring(ZipObj.read('AnimData.xml'))
                    sprite_sheets[spriteg2_data[i]] = [sprite_overwrite_index,int(tree.find('ShadowSize').text)]

                    mmb_bytes = FileType.WAN.CHARA.serialize(monster)
                    mmb_data = FileType.PKDPX.serialize(FileType.PKDPX.compress(mmb_bytes))
                    mmb_model[sprite_overwrite_index] = mmb_data

                    mgb_bytes = FileType.WAN.CHARA.serialize(ground)
                    mgb_model[sprite_overwrite_index] = mgb_bytes

                    mab_bytes = FileType.WAN.CHARA.serialize(attack)
                    mab_data = FileType.PKDPX.serialize(FileType.PKDPX.compress(mab_bytes))
                    mab_model[sprite_overwrite_index] = mab_data

                    sprite_overwrite_index = sprite_overwrite_index + 1

                sprite_index_g2 = sprite_sheets[spriteg2_data[i]]
                if (i+mon_count) < len(md_model.entries):
                    md_model.entries[i+mon_count].sprite_index = sprite_index_g2[0]
                    md_model.entries[i+mon_count].shadow_size = sprite_index_g2[1]

                    tile_slots, file_size = self._get_sprite_properties(md_model.entries[i+mon_count])
                    if expanded_pokelist:
                        md_model.entries[i+mon_count].unk17 = tile_slots
                        md_model.entries[i+mon_count].unk18 = file_size
                    else:
                        rom_sprite_table[i].sprite_tile_slots = max(tile_slots,rom_sprite_table[i].sprite_tile_slots);
                        rom_sprite_table[i].unk1 = max(file_size,rom_sprite_table[i].unk1)


        HardcodedMonsterSpriteDataTable.set(rom_sprite_table, rom.arm9, config)
        rom.setFileByName("MONSTER/monster.bin", BinPackHandler.serialize(mmb_model))
        rom.setFileByName("MONSTER/m_ground.bin", BinPackHandler.serialize(mgb_model))
        rom.setFileByName("MONSTER/m_attack.bin", BinPackHandler.serialize(mab_model))
        rom.setFileByName("BALANCE/monster.md", MdHandler.serialize(md_model))

    def unapply(self, unapply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        print("UNAPPLY")

    def _get_portrait_name(self, subindex):
        static_data = get_ppmdu_config_for_rom(self._cur_rom)

        portrait_name = static_data.script_data.face_names__by_id[math.floor(subindex / 2)].name.replace('-', '_')
        portrait_name = f'{subindex}: {portrait_name}'
        if subindex % 2 != 0:
            portrait_name += _(' (flip)')
        return portrait_name

    def _get_sprite_properties(self, entry):
        if entry.sprite_index < 0:
            return 0, 0

        sprite_bin = self._monster_bin[entry.sprite_index]
        sprite_bytes = FileType.COMMON_AT.deserialize(sprite_bin).decompress()
        sprite = FileType.WAN.deserialize(sprite_bytes)
        meta_frames = []
        for g in sprite.model.meta_frame_store.meta_frame_groups:
            meta_frames += g.meta_frames
        max_tile_slots_needed = max(
            (f.image_alloc_counter & 0x3FF) + math.ceil(f.resolution.x * f.resolution.y / 256)
            for f in meta_frames
        )
        max_tile_slots_needed = max((6, max_tile_slots_needed))
        max_file_size_needed = math.ceil(len(sprite_bytes) / 512)
        return max_tile_slots_needed, max_file_size_needed
