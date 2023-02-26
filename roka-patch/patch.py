#  Copyright 2020 Parakoopa
#
#  This file is part of SkyTemple.
#
#  SkyTemple is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  SkyTemple is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with SkyTemple.  If not, see <https://www.gnu.org/licenses/>.
from typing import Callable
import os

from ndspy.rom import NintendoDSRom

from skytemple_files.common.ppmdu_config.data import Pmd2Data, GAME_VERSION_EOS, GAME_REGION_US, GAME_REGION_EU
from skytemple_files.patch.handler.abstract import AbstractPatchHandler

from skytemple_files.patch.patches import Patcher
from skytemple_files.graphics.kao.sprite_bot_sheet import SpriteBotSheet
from skytemple_files.data.str.handler import StrHandler
from skytemple_files.common.util import *
from skytemple.core.string_provider import StringType
from skytemple_files.data.md.handler import MdHandler
from skytemple_files.graphics.kao.handler import KaoHandler

# EU
PATCH_APPLIED_ADDR_EU = 0x0230eba4
PATCH_APPLIED_VALUE_EU = 0x0000a0e1

PATCH_APPLIED_ADDR_NA = 0x022df910
PATCH_APPLIED_VALUE_NA = 0x0000a0e1

# text replacement data
TEXT_START_BLOCK_EU = 0x3FD0
TEXT_START_BLOCK_NA = 0x3FCE
EXTENDED_PKMN_STR_START_EU = 0x4833
EXTENDED_PKMN_STR_START_NA = 0x4814

EXTENDED_PKMN_COUNT = 2048
ROKA_PKMN_ID = 0x0000



# .definelabel CONFIG_TEXT_ID_INTRO_CLEAN_SAVEGAME, 0x3FCE ; 16334
# .definelabel CONFIG_TEXT_ID_INTRO_DIRTY_SAVEGAME, 0x3FCF ; 16335
# .definelabel CONFIG_TEXT_ID_BEFORE_WE_START, 0x3FD0 ; 16336
# .definelabel CONFIG_TEXT_ID_QUESTION_IF_NUZLOCKE, 0x3FD1 ; 16337
# .definelabel CONFIG_TEXT_ID_STUNNED_THAT_NO, 0x3FD2 ; 16338
# .definelabel CONFIG_TEXT_ID_SIGH_HAVE_FUN, 0x3FD3 ; 16339
# .definelabel CONFIG_TEXT_ID_HERE_ARE_THE_QUESTIONS, 0x3FD4 ; 16340
# .definelabel CONFIG_TEXT_CONFIG_DONE, 0x3FD5 ; 16341

# .definelabel CONFIG_TEXT_ID_QUESTION_FORCE_RECRUITE, 0x3FD6 ; 16342
# .definelabel CONFIG_TEXT_ID_QUESTION_FORCE_NAME, 0x3FD7 ; 16343


LANG_STRING_ASOC = {
"MESSAGE/text_e.str": [
    "Hello! My name is Roka and welcome to:\n[CN]Pokémon Mystery Dungeon: Explorers of Sky\n[CN]Nuzlocke Version\nIt seemes that you just started a new game.",
    "Hello! My name is Roka and welcome to:\n[CN]Pokémon Mystery Dungeon: Explorers of Sky\n[CN]Nuzlocke Version\nIt seemes your are playing with a savegame\nfrom a non nuzlocke version of the game.\n\nI will try my best to convert the save data\nbut there might be information missing like\nwhich pokemon are captured in which dungeons.",
    "Before you can start playing the game i have\nto ask you some questions to set up the\nappropiate nuzlocke rules.\nSo lets get right to it!",
    "Do you want to use any nuzlocke rules at all\nwhile playing the game?",
    "Wha- ...\nyou are playing a nuzlocke version of the game\nand you don't want nuzlocke rules????",
    "Fine ...\nThe game is set so no rules are applied ...\n[CN]Have fun playing.",
    "Good, the next questions will directly affect\nyour gameplay, so pay attention!",
    "And we are done!\n\n\nThe game is now set to enforce the rules\naccording to the answers you just gave.\n[CN]Have fun playing!",
    "Should the game force you to recruite a\nPokémon when they want to join?",
    "Should the game force you to give a nickname\nto a new recruite?",
    "Should the game force you to be able to\nrecruite only one Pokémon per dungeon?",
    "Do you want to disallow duplicated Pokémon?\n\n\nThis means that if you already have a\nPokémon on the team you are not allowed to\nrecruite another one of that species.",
    "Should the evolution line of a Pokémon\ncount as duplicated Pokémon?",
    "Should every Pokémon ever caught count as\nduplicated Pokémon? This would include\nPokémon no longer on the team.",
    "Should the hero count against the\nduplication rule?",
    "Should the partner count against\nthe duplication rule?",
    "Should marked as dead Pokémon count against\nthe duplication rule?",
    "Should the different gender count as\nseperate Pokémon when it comes to\nthe duplication rule?",
    "Should Pokémon be marked as 'dead' when\nthey faint?",
    "Do you want that reviver seeds no longer\nwork inside dungeons?",
    ],
"MESSAGE/text_f.str": [],
"MESSAGE/text_g.str": [],
"MESSAGE/text_i.str": [],
"MESSAGE/text_s.str": [],
}

class PatchHandler(AbstractPatchHandler):

    @property
    def name(self) -> str:
        return 'NuzlockeMode'

    @property
    def description(self) -> str:
        return "Adds nuzlocke rules to the game! Not compatible with DisableTips and unknown compatibility with other patches. Still very experimental ..."

    @property
    def author(self) -> str:
        return 'Roka'

    @property
    def version(self) -> str:
        return '0.0.1'

    def is_applied(self, rom: NintendoDSRom, config: Pmd2Data) -> bool:
        #if config.game_version == GAME_VERSION_EOS:
        #    if config.game_region == GAME_REGION_US:
        #        return ( read_u32(rom.arm9, PATCH_APPLIED_ADDR_NA) == PATCH_APPLIED_VALUE_NA)
        #    if config.game_region == GAME_REGION_EU:
        #        return ( read_u32(rom.arm9, PATCH_APPLIED_ADDR_EU) == PATCH_APPLIED_VALUE_EU)
        #raise NotImplementedError()
        return False

    def apply(self, apply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):

        if config.game_region == GAME_REGION_US:
            extended_pkmn_str_start = EXTENDED_PKMN_STR_START_NA
            text_block_start = TEXT_START_BLOCK_NA
        if config.game_region == GAME_REGION_EU:
            extended_pkmn_str_start = EXTENDED_PKMN_STR_START_EU
            text_block_start = TEXT_START_BLOCK_EU

        param = self.get_parameters()

        # Get the location of our 'patch.py' because we need to load addional files from there!
        pwd = os.path.dirname(os.path.realpath(__file__))
        self._cur_rom = rom

        patcher = Patcher(rom, get_ppmdu_config_for_rom(rom))
        expanded_pokelist = False
        if patcher.is_applied("ExpandPokeList"):
            print(f'Working with expanded pokemon list!')
            expanded_pokelist = True

        print(f'Patching strings:')

        # Go over every text file in the rom
        for filename in get_files_from_rom_with_extension(rom, "str"):
            # Try to update text entrys
            try:
                # Load the original Text data from the rom
                bin_before = rom.getFileByName(filename)
                strings = StrHandler.deserialize(bin_before)

                if filename in LANG_STRING_ASOC:
                    # Look at what file to load to get our new names from
                    string_list = LANG_STRING_ASOC[filename]
                    if(len(string_list) == 0):
                        string_list = LANG_STRING_ASOC["MESSAGE/text_e.str"]

                    if(len(string_list)):
                        for x in range(0,len(string_list)):
                            print(f'    Patching string[{text_block_start + x}]!')
                            strings.strings[text_block_start + x - 1] = string_list[x]

                    print(f'    Patching name of pokemon {param["_param_roka_pokemon_id"]}')
                    if expanded_pokelist:
                        if param["_param_roka_pokemon_id"] < EXTENDED_PKMN_COUNT:
                            strings.strings[extended_pkmn_str_start + param["_param_roka_pokemon_id"] - 1] = "Roka"
                        else:
                            raise UserValueError(f'Parameter roka_pokemon_id can not be greater then {EXTENDED_PKMN_COUNT-1}')

                    else:
                        block = config.string_index_data.string_blocks["Pokemon Names"]
                        block_len = block.end - block.begin
                        if param["_param_roka_pokemon_id"] < block_len:
                            strings.strings[param["_param_roka_pokemon_id"]+block.begin] = "Roka"
                        else:
                            raise UserValueError(f'Parameter roka_pokemon_id can not be greater then {block_len-1}')

                # Save our new text data
                bin_after = StrHandler.serialize(strings)
                rom.setFileByName(filename, bin_after)

            except:
                print(f'Could not update {filename} ...')
                raise

        print(f'Patching portait of pokemon {param["_param_roka_pokemon_id"]}')

        # Create fresh portrait data
        kao_bin = rom.getFileByName("FONT/kaomado.kao")
        kao_model = KaoHandler.deserialize(kao_bin)

        p_sheet = SpriteBotSheet.load(f'{pwd}/roka/roka.png', self._get_portrait_name)
        # go over every portrait and set the new image
        for subindex, image in p_sheet:
            kao_model.set_from_img(param["_param_roka_pokemon_id"]-1, subindex, image)

        # Save our portrait data
        rom.setFileByName("FONT/kaomado.kao", KaoHandler.serialize(kao_model))


        print(f'Patching binarys')
        apply()

    def unapply(self, unapply: Callable[[], None], rom: NintendoDSRom, config: Pmd2Data):
        raise NotImplementedError()

    def _get_portrait_name(self, subindex):
        static_data = get_ppmdu_config_for_rom(self._cur_rom)

        portrait_name = static_data.script_data.face_names__by_id[math.floor(subindex / 2)].name.replace('-', '_')
        portrait_name = f'{subindex}: {portrait_name}'
        if subindex % 2 != 0:
            portrait_name += _(' (flip)')
        return portrait_name
