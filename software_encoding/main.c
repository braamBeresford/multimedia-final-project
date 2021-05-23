/*
    Filename: main.c
    Author: Tristan Luther
    Date: 4/16/2021
    Purpose: Main entry Point for Software Implementation of C JPEG Encoding for Performance/Comparison Testing
*/

/********************* Includes **********************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/********************* Macros/Typedef **********************/


/********************* Functions **********************/

//Print out a macroblock to the screen
void printMacroblock(float block[8][8]){
    int i = 0, j = 0;
    for(i = 0; i < 8; i++){
        for(j = 0; j < 8; j++){
            printf(" %.2f\t ", block[i][j]);
        }
        printf("\n");
    }
    printf("\n");
    return;
}

//Print out a macroblock after zig-zag to the screen
void printLinear(float block[64]){
    int i = 0, j = 0;
    for(i = 0; i < 64; i++){
        printf(" %.2f\t ", block[i]);
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

//C value dependent on frequency and macroblock position
float C(int k){
  if(k == 0){
      return (1.0/sqrt(8));
  }
  else{
      return (sqrt(2)/sqrt(8));
  }
}

//Preform the Discrete Fouirer Transform on the 8x8 Macroblock
void DCT(float block[8][8], float dct[8][8]){
    //Loop interators
    int i = 0, j = 0, k = 0, l = 0;
    float dct_val = 0.0;
    float sum;
    //Loop through the entire macroblock
    for(i = 0; i < 8; i++){
        for(j = 0; j < 8; j++){
            sum = 0.0;
            //Loop though again to retive the DCT value
            for(k = 0; k < 8; k++){
                for(l = 0; l < 8; l++){
                    dct_val = block[k][l] * cos((2 * k + 1) * i * M_PI / (2 * 8)) * cos((2 * l + 1) * j * M_PI / (2 * 8));
                    sum = sum + dct_val;
                }
            }
            //Place that in the macroblock
            dct[i][j] = C(i) * C(j) * sum;
        }
    }
    return;
}

//Quantization on the macroblock
void quantize(float block[8][8]){
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

//Use zig-zag ordering on the macroblock
void zigzag(float block[8][8], float block_zig[64]){
    int i=0,j=0,k=0,d=0;
    while(k<36){
        block_zig[k++] = block[i][j];
        //On row zero and even number column
        if((i==0)&&(j%2==0)){
            j++;
            d=1;
        }
        //On column zero and odd number row
        else if((j==0)&&(i%2==1)){
            i++;
            d=0;
        }
        //Flip flop row/column
        else if(d==0){
            i--;
            j++;
        }
        else{
            i++;
            j--;
        }
    }
    i = 7;
    j = 1;
    d = 0;
    while(k<64){
        block_zig[k++] = block[i][j];
        //On row seven and even number column
        if((i==7)&&(j%2==0)){
            j++;
            d=0;
        }
        //On column seven and odd number row
        else if((j==7)&&(i%2==1)){
            i++;
            d=1;
        }
        //Flip flop row/column
        else if(d==0){
            i--;
            j++;
        }
        else{
            i++;
            j--;
        }
    }
    return;
}

//Run length encoding over a single macroblock after its zig-zag scan
int RunLengthEncoding(float in[64], float out[64]){
    int rl = 1;
    int i = 1;
    int k = 0;
    //Preserve the first block of the macroblock
    in[0] = out[0];
    //While we have not reached the end of the macroblock
    while(i < 64){
        k = 0;
        while((i < 64)&&(in[i] == 0)&&(k < 15)){
            i++;
            k++;
        }
        //Reached the end of the block
        if(i == 64){
            out[rl++] = 0;
            out[rl++] = 0;
        }
        //AC Coeff
        else{ 
            out[rl++] = k;
            out[rl++] = in[i++];
        }
    }
    if(!(out[rl-1] == 0 && out[rl-2] == 0)){
        out[rl++] = 0;
        out[rl++] = 0;
    }
    if((out[rl-4] == 15) && (out[rl-3] == 0)){
        out[rl-4] = 0;
        rl -= 2;
    }
    return rl;
}

//Get the equivalent scaled down value
int getCat(int a)
{
  if(a==0){
	return 0;
  }
  else if(abs(a)<=1){
	return 1;
  }
  else if(abs(a)<=3){
	return 2;
  }
  else if(abs(a)<=7){
	return 3;
  }
  else if(abs(a)<=15){
	return 4;
  }
  else if(abs(a)<=31){
	return 5;
  }
  else if(abs(a)<=63){
	return 6;
  }
  else if(abs(a)<=127){
	return 7;
  }
  else if(abs(a)<=255){
	return 8;
  }
  else if(abs(a)<=511){
	return 9;
  }
  else if(abs(a)<=1023){
	return 10;
  }
  else if(abs(a)<=2047){
	return 11;
  }
  else if(abs(a)<=4095){
	return 12;
  }
  else if(abs(a)<=8191){
	return 13;
  }
  else if(abs(a)<=16383){
	return 14;
  }
  else{
	return 15;
  }
}

//Compress the array based on the DC coefficient table
void DCencoding(float DCcoeff, int *length, unsigned char *compressed_out){
    //DC Coefficient table
    unsigned char codeLen[12] = {3,4,5,5,7,8,10,12,14,16,18,20};
    unsigned char code[12] = {0x02, 0x03, 0x04, 0x00, 0x05, 0x06, 0x0E, 0x1E, 0x3E, 0x7E, 0xFE, 0x1F}; //0x1FEs
    int cat = getCat(DCcoeff);
    *length = codeLen[cat];
    *compressed_out = code[cat];
    int j;
    int c = DCcoeff;
    if(DCcoeff < 0){
        c += (int)pow(2,cat)-1;
    }
    for(j = (*length)-1; j > ((*length)-cat)-1; j--){
        if(c % 2 == 1){
            compressed_out[j] = 0x01;
        }
        else{
            compressed_out[j] = 0x00;
        }
        c /= 2;
    }
    return;
}

//Compress the array based on the AC coefficient table
void ACencoding(int run_length, float code_n, int *length, char *compressed_out){
    //AC Coefficient tables
    int codeLen[16][11] = {
        4 ,3 ,4 ,6 ,8 ,10,12,14,18,25,26,
        0 ,5 ,8 ,10,13,16,22,23,24,25,26,
        0 ,6 ,10,13,20,21,22,23,24,25,26,
        0 ,7 ,11,14,20,21,22,23,24,25,26,
        0 ,7 ,12,19,20,21,22,23,24,25,26,
        0 ,8 ,12,19,20,21,22,23,24,25,26,
        0 ,8 ,13,19,20,21,22,23,24,25,26,
        0 ,9 ,13,19,20,21,22,23,24,25,26,
        0 ,9 ,17,19,20,21,22,23,24,25,26,
        0 ,10,18,19,20,21,22,23,24,25,26,
        0 ,10,18,19,20,21,22,23,24,25,26,
        0 ,10,18,19,20,21,22,23,24,25,26,
        0 ,11,18,19,20,21,22,23,24,25,26,
        0 ,12,18,19,20,21,22,23,24,25,26,
        0 ,13,18,19,20,21,22,23,24,25,26,
        12,17,18,19,20,21,22,23,24,25,26
    };
    unsigned short code[16][11] = {
        0xa,  0x0,  0x1,  0x4,  0xb,  0x1a,  0x38,  0x78,  0x3f6,  0xff82,  0xff83,
        0x0,0xc,0x39,0x79,0x1f6,0x7f6,0xff84,0xff85,0xff86,0xff87,0xff88,
        0x0,0x1b,0xf8,0x3f7,0xff89,0xff8a,0xff8b,0xff8c,0xff8d,0xff8e,0xff8f,
        0x0,0x3a,0x1f7,0x7f7,0xff90,0xff91,0xff92,0xff93,0xff94,0xff95,0xff96,
        0x0,0x3b,0x3f8,0xff97,0xff98,0xff99,0xff9a,0xff9b,0xff9c,0xff9d,0xff9e,
        0x0,0x7a,0x3f9,0xff9f,0xffa0,0xffa1,0xffa2,0xffa3,0xffa4,0xffa5,0xffa6,
        0x0,0x7b,0x7f8,0xffa7,0xffa8,0xffa9,0xffaa,0xffab,0xffac,0xffad,0xffae,
        0x0,0xf9,0x7f9,0xffaf,0xffb0,0xffb1,0xffb2,0xffb3,0xffb4,0xffb5,0xffb6,
        0x0,0xfa,0x7fc0,0xffb7,0xffb8,0xffb9,0xffba,0xffbb,0xffbc,0xffbd,0xffbe,
        0x0,0x1f8,0xffbf,0xffc0,0xffc1,0xffc2,0xffc3,0xffc4,0xffc5,0xffc6,0xffc7,
        0x0,0x1f9,0xffc8,0xffc9,0xffca,0xffcb,0xffcc,0xffcd,0xffce,0xffcf,0xffd0,
        0x0,0x1fa,0xffd1,0xffd2,0xffd3,0xffd4,0xffd5,0xffd6,0xffd7,0xffd8,0xffd9,
        0x0,0x3fa,0xffda,0xffdb,0xffdc,0xffdd,0xffde,0xffdf,0xffe0,0xffe1,0xffe2,
        0x0,0x7fa,0xffe3,0xffe4,0xffe5,0xffe6,0xffe7,0xffe8, 0xffe9,0xffea,0xffeb,
        0x0,0xff6,0xffec,0xffed,0xffee,0xffef,0xfff0,0xfff1,0xfff2,0xfff3,0xfff4,
        0xff7,0xfff5,0xfff6,0xfff7,0xfff8,0xfff9,0xfffa,0xfffb,0xfffc,0xfffd,0xfffe
    };

    int cat = getCat(code_n);
    *length = codeLen[run_length][cat];
    compressed_out[0] = code[run_length][cat];
    int j;
    int c = code_n;
    if(code_n < 0){
        c += (int)pow(2,cat)-1;
    }
    for(j = (*length)-1; j > ((*length)-cat)-1; j--){
        if(c % 2 == 1){
            compressed_out[j] = 0x01;
        }
        else{
            compressed_out[j] = 0x00;
        }
        c /= 2;
    }
    return; 
}

//Apppend the header information to the top of the jpeg file
void AppendHeader(FILE *fp, int dimx, int dimy){
    //Just to keep things neat this is its own function; Most of this is standard for JPG files
    //JPEG files are formatted in little endian
    /************************* Start of Image ************************/
    unsigned char soi[2] = {0xFF, 0xD8};
    fwrite(soi, 1, sizeof(soi), fp); //Append the start of file 0xFFD8
    /************************* Application ************************/
    unsigned char application[16] = {0xFF, 0xE0, 0x00, 0x10, 'J', 'F', 'I', 'F', 0x00, 0x01, 0x01, 0x01, dimx, dimy, 0x00, 0x00};
    fwrite(application, 1, sizeof(application), fp);
    /************************* Quantization/Luminance ************************/
    unsigned char quantization_lum[69] = {0xFF, 0xDB, 0x00, 0x43, 0x01,
        16,11,10,16,24,40,51,61,
        12,12,14,19,26,58,60,55,
        14,13,16,24,40,57,69,56,
        14,17,22,29,51,87,80,62,
        18,22,37,56,68,109,103,77,
        24,35,55,64,81,104,113,92,
        49,64,78,87,103,121,120,101,
        72,92,95,98,112,100,103,99};
    fwrite(quantization_lum, 1, sizeof(quantization_lum), fp);
    /************************* Quantization/Chrominance ************************/
    //Not applicable for this demo
    /************************* Start of Frame ************************/
    unsigned char sof[14] = {0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x02, 0x00, 0x06, 0x03, 0x01, 0x22, 0x00, 0x2};
    fwrite(sof, 1, sizeof(sof), fp);
    /************************* DC Huffman Table (luminance) ************************/
    unsigned char dc_huff[5] = {0xFF, 0xC4, 0x00, 0x0C, 0x00};
    //DC Coefficient table
    unsigned char codeLenDC[12] = {3,4,5,5,7,8,10,12,14,16,18,20};
    unsigned char codeDC[12] = {0x02, 0x03, 0x04, 0x00, 0x05, 0x06, 0x0E, 0x1E, 0x3E, 0x7E, 0xFE, 0x1F}; //0x1FEs
    fwrite(dc_huff, 1, sizeof(dc_huff), fp);
    fwrite(codeLenDC, 1, sizeof(codeLenDC), fp);
    fwrite(codeDC, 1, sizeof(codeDC), fp);

    /************************* DC Huffman Table (chrominance) ************************/
    //Not applicable for this demo

    /************************* AC Huffman Table (luminance) ************************/
    unsigned char ac_huff[5] = {0xFF, 0xC4, 0x00, 0xB0, 0x11};
    //AC Coefficient tables
    int codeLenAC[176] = {
        4 ,3 ,4 ,6 ,8 ,10,12,14,18,25,26,
        0 ,5 ,8 ,10,13,16,22,23,24,25,26,
        0 ,6 ,10,13,20,21,22,23,24,25,26,
        0 ,7 ,11,14,20,21,22,23,24,25,26,
        0 ,7 ,12,19,20,21,22,23,24,25,26,
        0 ,8 ,12,19,20,21,22,23,24,25,26,
        0 ,8 ,13,19,20,21,22,23,24,25,26,
        0 ,9 ,13,19,20,21,22,23,24,25,26,
        0 ,9 ,17,19,20,21,22,23,24,25,26,
        0 ,10,18,19,20,21,22,23,24,25,26,
        0 ,10,18,19,20,21,22,23,24,25,26,
        0 ,10,18,19,20,21,22,23,24,25,26,
        0 ,11,18,19,20,21,22,23,24,25,26,
        0 ,12,18,19,20,21,22,23,24,25,26,
        0 ,13,18,19,20,21,22,23,24,25,26,
        12,17,18,19,20,21,22,23,24,25,26
    };
    unsigned short codeAC[176] = {
        0xa,  0x0,  0x1,  0x4,  0xb,  0x1a,  0x38,  0x78,  0x3f6,  0xff82,  0xff83,
        0x0,0xc,0x39,0x79,0x1f6,0x7f6,0xff84,0xff85,0xff86,0xff87,0xff88,
        0x0,0x1b,0xf8,0x3f7,0xff89,0xff8a,0xff8b,0xff8c,0xff8d,0xff8e,0xff8f,
        0x0,0x3a,0x1f7,0x7f7,0xff90,0xff91,0xff92,0xff93,0xff94,0xff95,0xff96,
        0x0,0x3b,0x3f8,0xff97,0xff98,0xff99,0xff9a,0xff9b,0xff9c,0xff9d,0xff9e,
        0x0,0x7a,0x3f9,0xff9f,0xffa0,0xffa1,0xffa2,0xffa3,0xffa4,0xffa5,0xffa6,
        0x0,0x7b,0x7f8,0xffa7,0xffa8,0xffa9,0xffaa,0xffab,0xffac,0xffad,0xffae,
        0x0,0xf9,0x7f9,0xffaf,0xffb0,0xffb1,0xffb2,0xffb3,0xffb4,0xffb5,0xffb6,
        0x0,0xfa,0x7fc0,0xffb7,0xffb8,0xffb9,0xffba,0xffbb,0xffbc,0xffbd,0xffbe,
        0x0,0x1f8,0xffbf,0xffc0,0xffc1,0xffc2,0xffc3,0xffc4,0xffc5,0xffc6,0xffc7,
        0x0,0x1f9,0xffc8,0xffc9,0xffca,0xffcb,0xffcc,0xffcd,0xffce,0xffcf,0xffd0,
        0x0,0x1fa,0xffd1,0xffd2,0xffd3,0xffd4,0xffd5,0xffd6,0xffd7,0xffd8,0xffd9,
        0x0,0x3fa,0xffda,0xffdb,0xffdc,0xffdd,0xffde,0xffdf,0xffe0,0xffe1,0xffe2,
        0x0,0x7fa,0xffe3,0xffe4,0xffe5,0xffe6,0xffe7,0xffe8, 0xffe9,0xffea,0xffeb,
        0x0,0xff6,0xffec,0xffed,0xffee,0xffef,0xfff0,0xfff1,0xfff2,0xfff3,0xfff4,
        0xff7,0xfff5,0xfff6,0xfff7,0xfff8,0xfff9,0xfffa,0xfffb,0xfffc,0xfffd,0xfffe
    };
    fwrite(ac_huff, 1, sizeof(ac_huff), fp);
    fwrite(codeLenAC, 1, sizeof(codeLenAC), fp);
    fwrite(codeAC, 1, sizeof(codeAC), fp);

    /************************* Start of Scan ************************/
    unsigned char sos[] = {0xFF, 0xDA, 0x00, 0x0C, 0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3F, 0x00};
    fwrite(sos, 1, sizeof(sos), fp);
    //Following will be the image data macroblocks
    return; //Go back to call point
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

    //Output to be written out to the fileout
    unsigned char writecode[80*80*26*32];
    writecode[0] = '\0';

    //Get the image RGB data (each pixel)
    //Declare an array of pixels the size of the image
    unsigned char data[dimx*dimy][3];
    //Figure out how many macroblocks will be in this image
    unsigned char macro_x = ((dimx+7)/8);
    unsigned char macro_y = ((dimy+7)/8);
    float macro[macro_x*macro_y*3][8][8];
    //size_t read = fread(data, dimx*dimy, sizeof(unsigned char), input_fp);
    int i = 0, j = 0, k = 0, l = 0, m = 0;
    for(i = 0; i < dimx*dimy; i++){
        fread(&data[i], 3, 1, input_fp);
        //Convert each of these pixels to YUV
        rgb_to_yuv(data[i]);
        //If we have reached the end of a macroblock
        if(i % 64 == 0){
            //Increment the macroblock iterator/reset
            k++;
            l = 0;
            m = 0;
        }
        macro[k][l][m] = data[i][0]; //Only take the luminance
        m++;
        //If we have reached the end of a row in a macroblock
        if(m == 8){
            m = 0; //Reset the row and add a to column
            l++;
        }
    }
    //Pass the macroblocks through the DCT
    for(i = 0; i < (macro_x*macro_y); i++){
        //Declare dct var
        static float dct[8][8];
        DCT(macro[i], dct);
        //Update that macroblock
        for(j = 0; j < 8; j++){
            for(k = 0; k < 8; k++){
                macro[i][k][j] = dct[k][j];
            }
        }
        //Quantize the macroblock
        quantize(macro[i]);
        //Zig-zag scan through the block
        float macro_linear[64];
        zigzag(macro[i], macro_linear);
        float run_length[64];
        //Complete the run length encoding
        int rl = RunLengthEncoding(macro_linear, run_length);
        unsigned char compressed_out[32]; 
        int length = 0;
        DCencoding(run_length[0], &length, compressed_out);
        strcat(writecode, compressed_out);
        //Loop over the run length and encode the AC coefficients
        for(j = 1; j < rl; j+=2){
            ACencoding(run_length[j], run_length[j+1], &length, compressed_out);
            //Append the results to the final output
            strcat(writecode, compressed_out);
        }
    }

    //Append the header information to the output file
    AppendHeader(output_fp, dimx, dimy);

    //Write all of the image data out to the output file
    fwrite(writecode, 1, sizeof(writecode), output_fp);
    
    //Write the end of image byte
    unsigned char eof[2] = {0xFF, 0xD9}; 
    fwrite(eof, 1, sizeof(eof), output_fp);

    //Close the input file
    fclose(input_fp);

    printf("\nOutput: %s\n", file_name_out);

    //Close the output file
    fclose(output_fp);

    return 0; //Everything went fine
}