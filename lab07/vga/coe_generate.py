#!/usr/bin/python
import sys
from PIL import Image

# global parameters
coe_path = "out.coe"

def generate(pic_path,coe_path):
    '''
    parse a image to get the highest 4 bits of r,g,b
    :param path: picture path
    :return: array of pix, scanned by line
    '''
    pix_arr = []
    im = Image.open(pic_path)
    pix = im.load()

    width = im.size[0]
    height = im.size[1]
    print("image width=%d,height=%d" % (width, height))
    
    with open(coe_path,'w') as f:
        f.write("memory_initialization_radix=16;\nmemory_initialization_vector=\n")
        for x in range(width):
            for y in range(height):
                if im.mode=="RGB":
                    r, g, b = pix[x, y] #for RGB figures
                else:
                    r, g, b, a= pix[x, y] #for RGBA figures
                r = (r & 0xF0) >> 4
                g = (g & 0xF0) >> 4
                b = (b & 0xF0) >> 4
                f.write("%X%X%X"%(r, g, b))
                if x == (width-1) and y == (height-1):
                    f.write(";\n")
                else:
                    f.write(",\n")
    print("finish successful!!")

if __name__ == "__main__":
    # useage: python coe_generate.py path-to-picture-file
    pic_path = sys.argv[1]
    generate(pic_path,coe_path)
