/*
    Filename: main.c
    Author: Tristan Luther
    Date: 4/16/2021
    Purpose: Main entry Point for Software Implementation of C JPEG Encoding
*/

/********************* Includes **********************/
#include <stdio.h>
#include <stdlib.h>

/********************* Macros/Typedef **********************/
//Type definition for holding pixel values
typedef struct {
    int r;
    int g;
    int b;
} RGBPixel;

/********************* Functions **********************/
//Step through the RGB file and read the RGB values output to a YUV file of the same name
void rgb_to_yuv(FILE *input_fp){
    /*
        According to JPEG standard:
        Y  =  0.2989 R + 0.5866 G + 0.1145 B
        Cb = -0.1687 R - 0.3312 G + 0.5000 B
        Cr =  0.5000 R - 0.4183 G - 0.0816 B
    */
    const int dimx = 800, dimy = 800;
    //Place file contents into a buffer
    fprintf(input_fp, "P6\n%d %d\n255\n", dimx, dimy);
    return; //Go back to the call point
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
    //size_t read = fread(data, dimx*dimy, sizeof(unsigned char), input_fp);
    int i = 0;
    for(i = 0; i < dimx*dimy; i++){
        fread(&data[i], 3, 1, input_fp);
        printf("%d %d %d\n", data[i][0], data[i][1], data[i][2]);
    }
    //Close the input file
    fclose(input_fp);
    
    //Step through the RGB file and read the RGB values output to a YUV file of the same name
    //rgb_to_yuv(input_fp);
    printf("Output: %s\n", file_name_out);

    //Close the output file
    fclose(output_fp);

    //Free the memory allocated for pixels
    //free(data);
    return 0; //Everything went fine
}