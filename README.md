kMeansColorsRuby
================

Simple implementation applying k-means to an image

Largely a port of this code: http://charlesleifer.com/blog/using-python-and-k-means-to-find-the-dominant-colors-in-images/
and the example from http://shop.oreilly.com/product/9780596529321.do

To run the code:


    ruby lib/image_colors.rb path/to/image.{jpg,png,bmp}

This will print 3 colors that the clusters converge to and also write image files to 0.png, 1.png, and 2.png
for an easy way to preview the colors.
