# Pika-Patch
This is a patch to mass edit pokemon in skytemple in an automated way. Orginially created for changing every pokemon inside Skytemple to Mew ...

Running this patch can take several minutes so Skytemple will hang while the patch is working.

## Compatibility
This patch is compatible with the 'ExpandPokeList' patch included in Skytemple.

## Files
There are several files that control what the patch is doing

### names_*.txt
A list of names the pokemon should get. Every line corresponds to one pokemon with the id 'linenumber - 1' inside Skytemple. A empty line means no change to the name. The names for the different languages can be set with different files:

* names_e.txt: English
* names_f.txt: French
* names_g.txt: German
* names_i.txt: Italian
* names_s.txt: Spanish

### cat_*.txt
A list of categorys the pokemon should get. Every line corresponds to one pokemon with the id 'linenumber - 1' inside Skytemple. A empty line means no change to the category. The categorys for the different languages can be set with different files:

* cat_e.txt: English
* cat_f.txt: French
* cat_g.txt: German
* cat_i.txt: Italian
* cat_s.txt: Spanish

### portraits_gender1.txt and portraits_gender2.txt
A list of paths to the portraits for the gender of the pokemon. The text 'none' or a empty line will prevent any changes. Just like with the names and categorys one line corresponds to one pokemon. Importing portraits is a slow process and will make Skytemple hang for a bit.

### sprites_gender1.txt and sprites_gender2.txt
A list of paths to the sprites for the gender of the pokemon. The text 'none' or a empty line will prevent any changes. Just like with the names and categorys one line corresponds to one pokemon. Depending on how many different sprite are to be imported the process might take some time.

# Links
Demo sprites and portraits are from the [PMD Sprite Repository](https://sprites.pmdcollab.org/)
