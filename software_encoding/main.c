/*
    Filename: main.c
    Author: Tristan Luther
    Date: 4/16/2021
    Purpose: Main entry Point for Software Implementation of C JPEG Encoding
*/

/********************* Includes **********************/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/********************* Macros/Typedef **********************/


/********************* Functions **********************/

//Print out a macroblock to the screen
void printMacroblock(unsigned char block[8][8]){
    int i = 0, j = 0;
    for(i = 0; i < 8; i++){
        for(j = 0; j < 8; j++){
            printf(" %d ", block[i][j]);
        }
        printf("\n");
    }
    printf("\n");
    return;
}

//Print out a single pixel value
void printPixel(unsigned char pixel[3]){
    printf(" %d  %d  %d ", pixel[0], pixel[1], pixel[2]);
}

//Step through the RGB pixels and read the RGB values output to a YUV
void rgb_to_yuv(unsigned char *pixel_data){
    /*
        According to JPEG standard:
        Y  =  0.2989 R + 0.5866 G + 0.1145 B
        Cb = -0.1687 R - 0.3312 G + 0.5000 B
        Cr =  0.5000 R - 0.4183 G - 0.0816 B
    */
    unsigned char red = pixel_data[0];
    unsigned char green = pixel_data[1];
    unsigned char blue = pixel_data[2];
    //Y Pixel Data
    pixel_data[0] = 0.2989*red + 0.5866*green + 0.1145*blue;
    //Cb Pixel Data
    pixel_data[1] = -0.1687*red - 0.3312*green + 0.5000*blue;
    //Cr Pixel Data
    pixel_data[2] = 0.5000*red - 0.4183*green - 0.0816*blue;
    return; //Go back to the call point
}

float C(int u)
{
  if(u==0)
    return (1.0/sqrt(2.0));
  else
    return 1.0;
}

//Preform the Discrete Fouirer Transform on the 8x8 Macroblock
void DCT(unsigned char block[8][8]){
    //Loop interators
    int i = 0, j = 0, k = 0, l = 0;
    float dct_val;
    //Loop through the entire macroblock
    for(i = 0; i < 8; i++){
        for(j = 0; j < 8; j++){
            dct_val = 0.0;
            //Loop though again to retive the DCT value
            for(k = 0; k < 8; k++){
                for(l = 0; l < 8; l++){
                    dct_val += (float)(block[k][l])*cos((2.0*(float)(k)+1.0)*(float)(i)*3.14/16.0)*cos((2.0*(float)(l)+1.0)*(float)(j)*3.14/16.0);
                }
            }
            //Place that in the macroblock
            block[i][j] = (int)(0.25*C(i)*C(j)*dct_val);
        }
    }
}

//Quantization on the macroblock
void quantize(unsigned char block[8][8]){
    //Quantization table
    int quantization[8][8] = {
        16,11,10,16,24,40,51,61,
        12,12,14,19,26,58,60,55,
        14,13,16,24,40,57,69,56,
        14,17,22,29,51,87,80,62,
        18,22,37,56,68,109,103,77,
        24,35,55,64,81,104,113,92,
        49,64,78,87,103,121,120,101,
        72,92,95,98,112,100,103,99 
    };
    int i = 0, j = 0;
    //Divide the value in the DCT result macroblock by the quantization value
    for(i = 0; i < 8; i++){
        for(j = 0; j < 8; j++){
            block[i][j] = (int)(block[i][j]/quantization[i][j]);
        }
    }
    return;
}

//TODO Use zig-zag ordering on the macroblock
void zigzag(unsigned char block[8][8]){

    return;
}

/********************* Main **********************/
int main(int argc, char **argv){
    //Check total number of command line arguments
    if(argc != 3){
        printf("Usage: jpeg_encode input_file.ppm output_file.jpg\n");
        return 1;
    }
    //If # of arguments is correct check that the .raw is a file that can be opened
    char *file_name_in = argv[1];
    char *file_name_out = argv[2];

    //File pointers to open things up
    FILE *input_fp = fopen(file_name_in, "rb");
    FILE *output_fp = fopen(file_name_out, "wb"); 

    //Check the input file exists
    if(input_fp == NULL){
        printf("Could not open file \'%s\'", file_name_in);
        return 1;
    }
    //Check the output file exists
    if(output_fp == NULL){
        printf("Could not open file \'%s\'", file_name_out);
        return 1;
    }
    //Files are good!
    /*
    On a high level this is what needs to happen next:
        1. Convert this RGB ppm image to a YUV style image (illuminance and Chromance)
        2. Break up the image into 8x8 macroblocks (option to write out single 8x8 block for testing)
        3. Transform each macroblock into frequency domain using Discrete Cosine Transform (DCT)
        4. Quantize the information using the known quantization blocks
        5. Preform run length coding on each marcoblock
        6. Preform huffman encoding on each macroblock
        7. Write these macroblocks to a file that has the appropriate headers
    */
    //Get the image file metadata
    char type[3];
    int dimx = 0;
    int dimy = 0;
    int max = 0;
    fscanf(input_fp, "%s\n %d %d\n %d", type, &dimx, &dimy, &max);
    type[2] = '\0'; //Be sure that is terminated
    printf("File Type: %s\nDimensions: %d x %d\nMax Color Val: %d\n", type, dimx, dimy, max);

    //Get the image RGB data (each pixel)
    //Declare an array of pixels the size of the image
    unsigned char data[dimx*dimy][3]; // = malloc(dimx*dimy*sizeof(unsigned char));
    //Figure out how many macroblocks will be in this image
    unsigned char macro_x = ((dimx+7)/8);
    unsigned char macro_y = ((dimy+7)/8);
    unsigned char macro[macro_x*macro_y*3][8][8];
    //size_t read = fread(data, dimx*dimy, sizeof(unsigned char), input_fp);
    int i = 0, j = 0, k = 0, l = 0, m = 0;
    for(i = 0; i < dimx*dimy; i++){
        fread(&data[i], 3, 1, input_fp);
        //Convert each of these pixels to YUV
        rgb_to_yuv(data[i]);
        //Reformat the pixels into macroblocks
        for(j = 0; j < 3; j++){
            //If we have reached the end of a macroblock
            if((3*i+(j+1)) % 64 == 0){
                //Increment the macroblock iterator/reset
                k++;
                l = 0;
                m = 0;
            }
            macro[k][l][m] = data[i][j];
            //printf("%d %d %d\n", k, l, m);
            m++;
            //If we have reached the end of a row in a macroblock
            if(m == 8){
                m = 0; //Reset the row and add a to column
                l++;
            }
        }
    }
    //Pass the macroblocks through the DCT
    for(i = 0; i < (macro_x*macro_y*3); i++){
        DCT(macro[i]);
        //Quantize the macroblock
        quantize(macro[i]);
        //Zigzag ordering on block
        zigzag(macro[i]);

        printf("Number: %d\n", i);
        printMacroblock(macro[i]);
    }
    
    //Close the input file
    fclose(input_fp);
    
    //Step through the RGB file and read the RGB values output to a YUV file of the same name
    //rgb_to_yuv(input_fp);
    printf("\nOutput: %s\n", file_name_out);

    //Close the output file
    fclose(output_fp);

    //Free the memory allocated for pixels
    //free(data);
    return 0; //Everything went fine
}