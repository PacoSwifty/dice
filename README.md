# dice
Takes a source image, converts it to a grid of dice, and prints out instructions for recreating it with real dice.


# How to Use
* Must be run in Processing 2, not 3.
In the /images folder there is a file named source.jpg. Replace that file (while keeping the name the same) with whatever source image you would like to see recreated in dice.

# Flags
At the top of DiceProject.pde there are a couple of global variables you can change to affect your results. Firstly, there's a constant named `DICE_TYPE` that by default is set to `NORMALA_DICE`. You can change that to be any of the types directly above it (NORMAL/BLACK/WEIGHTED/INVERTED) to get different results in your output image. The WEIGHTED_DICE option will give you the best looking output image, but is not feasible to recreate with real nice. Essentially it uses different shades of white to help emphasize the effect of the higher-number dice.

# Output
Running the code produces a couple of helpful files. When run, you will see your image in a sample window but it will also be saved to a file called DicedImage.jpg in the root folder for the project. A text file called instructions.txt is also produced that will give you line-by-line instructions to recreate the diced image with physical dice, should you want to build a real-world instance of your image.
