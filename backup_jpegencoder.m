 
%% Clean Workplace
clear ;
close all;
clc;
%% Initialize Variables
check = 0;
stream=[];
header_file=[255	216	255	224	000	016	074	070	073	070	000	001	002	000	000	096	000	096	000	000	...
        255	219	000	067	000	016	011	012	014	012	010	016	014	013	014	018	017	016	019	024	...
        040	026	024	022	022	024	049	036	037	029	040	058	051	061	060	057	051	056	055	064	...
        072	092	078	064	068	087	069	055	056	080	109	081	087	095	098	103	194	103	062	077	...
        113	121	112	100	120	092	101	103	099	255	219	000	067	001	017	018	018	024	021	024	...
        047	026	026	047	099	066	056	066	099	099	099	099	099	099	099	099	099	099	099	099	...
        099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	...
        099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	099	255	192	...
        000	011	008	000	000	000	000	001	001	034	000	255	196	000	031	000	000	001	005	001	...
        001	001	001	001	001	000	000	000	000	000	000	000	000	001	002	003	004	005	006	007	...
        008	009	010	011	255	196	000	181	016	000	002	001	003	003	002	004	003	005 	005	004	...
        004	000	000	001	125	001	002	003	000	004	017	005	018	033	049	065	006	019	081	097	...
        007	034	113	020	050	129	145	161	008	035	066	177	193	021	082	209	240	036	051	098	...
        114	130	009	010	022	023	024	025	026	037	038	039	040	041	042	052	053	054	055	056	...
        057	058	067	068	069	070	071	072	073	074	083	084	085	086	087	088	089	090	099	100	...
        101	102	103	104	105	106	115	116	117	118	119	120	121	122	131	132	133	134	135	136	...
        137	138	146	147	148	149	150	151	152	153	154	162	163	164	165	166	167	168	169	170	...
        178	179	180	181	182	183	184	185	186	194	195	196	197	198	199	200	201	202	210	211	...
        212	213	214	215	216	217	218	225	226	227	228	229	230	231	232	233	234	241	242	243	...
        244	245	246	247	248	249	250	255	218	000	008	001	001	000	000	063	000];
% Start of Image (SOI) marker:FFD8=255,216
% JFIF marker:FFE0=255,224
%        Length=000,016
%        Identifier:4A46494600=074,070,073,070,000
%        Version=001,002
%        Units=000
%        Xdensity=000,096
%        Ydensity=000,096
%        Xthumbnail=000
%        Ythumbnail=000
%        (RGB)n, n=Xthumbnail*Ythumbnail required 3*n bytes=null
% Define Quantization table marker (luma):FFDB=255,219
%         Length:two bytes that indicate the number of bytes, including the two length bytes, that this header contains=000,067
%         Precision=000 (baseline)
%         Quantization values=016,011,012,014,012,010,016,...,101,103,099 (zigzag)
% Define Quantization table marker (Chroma):FFDB=255,219
%         Length:two bytes that indicate the number of bytes, including the two length bytes, that this header contains=000,067
%         Precision=000 (baseline)
%         Quantization values=017,018,018,024,021,024,047,...,099,099,099 (zigzag)
% Start of frame marker:FFC0=255,192
%         Length:two bytes that indicate the number of bytes, including the two length bytes, that this header contains=000,011
%         Sample precision=008
%         X=000,000 (This will be defined later)
%         Y=000,000 (This will be defined later)
%         Number of components in the image=001
%             * 3 for color baseline
%             * 1 for grayscale baseline
%         Component ID=001
%         H and V sampling factors=034
%         Quantization table number=000
% Define Huffman table marker (DC):FFC4=255,196
%        Length:two bytes that indicate the number of bytes, including the two length bytes, that this header contains=000,031
%        Index=000 (Huffman DC)
%        Bits=The next 16 bytes from an array of unsigned 1-byte integers whose elements give the number of Huffman codes for each possible code length (1-16).
%        Huffman values=000,001,002,...,010,011
% Define Huffman table marker (AC):FFC4=255,196
%        Length:two bytes that indicate the number of bytes, including the two length bytes, that this header contains=000,181
%        Index=016 (Huffman AC)
%        Bits=The next 16 bytes from an array of unsigned 1-byte integers whose elements give the number of Huffman codes for each possible code length (1-16).
%        Huffman values=001,002,003,...,249,250
% Start of Scan marker:FFDA=255,218
%        Length:two bytes that indicate the number of bytes, including the two length bytes, that this header contains=000,008
%        Number of components=001
%        Component ID=001
%        DC and AC table numbers=000
%        Ss=000
%        Se=063
%        Ah and Al=000
zigzag_index_quantizetable = [ ...
     1  2  6  7 15 16 28 29
     3  5  8 14 17 27 30 43
     4  9 13 18 26 31 42 44
    10 12 19 25 32 41 45 54
    11 20 24 33 40 46 53 55
    21 23 34 39 47 52 56 61
    22 35 38 48 51 57 60 62
    36 37 49 50 58 59 63 64
    ];
Quantize_table_qf50=[...
    16 11 10 16 24 40 51 61;...
    12 12 14 19 26 58 60 55;...
    14 13 16 24 40 57 69 56;...
    14 17 22 29 51 87 80 62;...
    18 22 37 56 68 109 103 77;...
    24 36 55 64 81 194 113 92;...
    49 64 78 87 103 121 120 101;...
    72 92 95 98 112 100 103 99];
    QF = 50;    
    % Compute scaling factor
    if QF < 50
        S = 5000 / QF;
    else
        S = 200 - 2 * QF;
    end
    
    % Compute quantization table
    Quantize_table_qfchoice = floor((S * Quantize_table_qf50 + 50) / 100);
    
    % Quantizae table Replace zeros with 1
    Quantize_table_qfchoice(Quantize_table_qfchoice < 1) = 1;
    
    % Convert to zigzag vector
    qtable_vector = zeros(1,64);
    
    for row = 1:8
        for col = 1:8
            index = zigzag_index_quantizetable(row,col);
            qtable_vector(index) = Quantize_table_qfchoice(row,col);
        end
    end

    start_index = 26;
    end_index   = start_index + 63;

    header_file(start_index:end_index) = qtable_vector;
z=[...
    9 2 3 10 17 25 18 11 4 5 12 19 26 ...
    33 41 34 27 20 13 6 7 14 21 28 35 ...
    42 49 57 50 43 36 29 22 15 8 16 23 ...
    30 37 44 51 58 59 52 45 38 31 24 32 ...
    39 46 53 60 61 54 47 40 48 55 62 63 56 64];
%% Read Image
    % Open file selection dialog for BMP images
        [file, location] = uigetfile('*.bmp');
    
    % Check whether user pressed Cancel
        if isequal(file, 0)
        % Display message if no file is selected
            disp('User selected Cancel');
        else
            % Read image data and colormap 
            [img, map] = imread(file);
            % Check whether image uses indexed color format
            if ~isempty(map) % Check whether image uses indexed color format
                % Convert indexed image to RGB image
                img = ind2rgb(img, map);
                % Convert double RGB image (0 to 1) into uint8 format (0 to 255)
                uint8image = im2uint8(img);
            else
                % If image is already RGB or grayscale, directly convert to uint8
                uint8image = uint8(imread(file));
            end
             % Convert image data to int32 for later  processing
            image = double(uint8image);
            % Get image dimensions
                % row  = image height
                % col  = image width
                % dim  = number of channels (e.g., 3 for RGB)
            [row, col, dim] = size(image);
        end

img_name = regexp(file,'\.','split');
img_name = img_name{1};

% %% PAD row:col for 8x8
    % if mod(row,8)~=0
    %     row_padding = row+(8-mod(row,8));
    % else
    %     row_padding = row;
    % end
    % if mod(col,8)~=0
    %     col_padding = col+(8-mod(col,8));
    % else
    %     col_padding = col;
    % end
%% PAD image size to 128x72 ratio

col_padding = ceil(max(col, row * 128 / 72) / 128) * 128;
row_padding = col_padding * 72 / 128;


image_padded = zeros(row_padding, col_padding,dim);

%% padding
for i=1:col
    for j=1:row
       for k = 1:3
          image_padded(j+round((row_padding-row)/2),i+round((col_padding-col)/2),k)=image(j,i,k);
       end
    end
end


% %% CREATE COE FILE
        %Y is row-width || X is col-length
        Y = dec2bin(row_padding,24);%24 bits
        X = dec2bin(col_padding,24);
        Rcoe = image_padded(:, :, 1);  % Red channel
        Gcoe = image_padded(:, :, 2);  % Green channel
        Bcoe = image_padded(:, :, 3);  % Blue channel

        num_blk_row = row_padding / 8;
        num_blk_col = col_padding / 8;
        num_blocks  = num_blk_row * num_blk_col;

        block_idx = 1;
        for i=1:8:row_padding
           for j=1:8:col_padding
               %convert dec2bin
               Rblk = uint8((Rcoe(i:i+7,j:j+7)).');
               Gblk = uint8((Gcoe(i:i+7,j:j+7)).');
               Bblk = uint8((Bcoe(i:i+7,j:j+7)).');
               blockR = dec2bin(Rblk(:), 8);
               blockG = dec2bin(Gblk(:), 8);
               blockB = dec2bin(Bblk(:), 8);
               %concat to size 64x24
               blockRGB = cat(2,blockR,blockG,blockB);

               if (block_idx == 1)
                  Blocks = blockRGB;
               else
                   Blocks = cat(1,Blocks,blockRGB);
               end
               block_idx = block_idx + 1;  
           end
        end

        pixelnum = dec2bin(size(Blocks,1),24);
        Blocks   = cat(1,X,Y,pixelnum,Blocks);

        write_rgb24_to_coe(['COE' img_name ...
            '.coe'], Blocks);
%%------------------------------------------------------------        
%% Convert Image To YCBCR
imgYCBCR = double(rgb2ycbcr(uint8(image_padded)));
imgY        = imgYCBCR(:,:,1) - 128;

% luminance02 = bitsra( int16(65) * int16(image_aspect(:,:,1)) + int16(128) * int16(image_aspect(:,:,2)) + int16(25) * int16(image_aspect(:,:,3)) +128 , 8) + int16(16);
% luminance2  = luminance02 - int16(128);
 format long g
% 
%% Segmenting Image Blocks Of 8x8
blocknum=0;
zig_zag_ac   = zeros(int16(row_padding*col_padding/64), 63);
zig_zag_dc   = zeros(int16(row_padding*col_padding/64), 1);

for i=1:8:row_padding
    for j=1:8:col_padding
        f  = imgY(i:i+7,j:j+7) ;
         
        T  = (winnograd(winnograd(f).')).';
        TQ = fix(T./Quantize_table_qf50);
        
        blocknum=blocknum+1;
        zig_zag_dc(blocknum,1) = TQ(1,1);
        zig_zag_ac(blocknum,1:63) = TQ(z);
    end
end
%% Huffman Compression
dpcm(1,1)=zig_zag_dc(1,1);

stream=cat(2,stream,huffman_dc(dpcm(1,1)),huffman_ac(zig_zag_ac(1,1:63)));
for m=2:blocknum
    dpcm(m,1)=zig_zag_dc(m,1)-zig_zag_dc(m-1,1);
    stream=cat(2,stream,huffman_dc(dpcm(m,1)),huffman_ac(zig_zag_ac(m,1:63)));
end

[matrix_code_decimal, matrixsize]   = bytestuff_2decimal(stream);
%% Final Marker
matrix_code_decimal(size(matrix_code_decimal,1) +1,1)=255;
matrix_code_decimal(size(matrix_code_decimal,1) +1,1)=217;

function [matrix_code_decimal, bytestream_size] = bytestuff_2decimal(stream)

%% Convert String To Decimal
   numbytes =floor(length(stream)/8);
   % diff_stream is number of LEFTOVER bits after convert to bytes
   diff_stream=length(stream)-numbytes*8;

   % if bitstream is divided by 8
   if diff_stream==0 
      bytestream= zeros(numbytes,8);
   % if bitstream is NOT divided by 8
   % add 1 slot for append bits
   else 
      bytestream= zeros(numbytes+1,8);
   end

   bytestream_size = 0;
   for count2=1:8:numbytes*8
      bytestream_size=bytestream_size+1;
      bytestream(bytestream_size,1)=bin2dec(stream(1,count2:count2+7));
   end

   % convert diff_stream to the last byte if size NOT divided by 8
   if diff_stream~=0
        remain = stream(numbytes*8+1 : end);

        % from xxxx1010 to 1111101
        remain = [ remain repmat('1',1,8-diff_stream)];

        bytestream_size = bytestream_size + 1;
        bytestream(bytestream_size,1) = bin2dec(remain);
   end
   
   %result is matrix_code_decimal; size (numbytes or numbytes + 1, 8)
%% Byte Stuffing
   matrix_code_decimal =[];
   for k = 1:(length(bytestream))
      b = bytestream(k);

      % Always append the byte
      matrix_code_decimal = [matrix_code_decimal; b];

      % JPEG stuff rule: FF must be followed by 00
      if b == 255
         matrix_code_decimal = [matrix_code_decimal; uint8(0)];
      end
   end
end

% %% Byte Stuffing
% p=0;
% G=size(stream,2);
% for i=1:8:size(stream,2)
%     bit_val(1,1:8)=stream(1,i:i+7);
%     if strcmp(bit_val(1,1:8),'11111111') ==1
%         tempbitstream = stream(1,i+8:G+p);
%         stream(1,i+8:i+15)='00000000';
%         p=p+8;
%         temp2_bitstream=stream(1,1:i+15);
%         stream(1,1:G+p)=cat(2,temp2_bitstream,tempbitstream);
%     end
% end
% %% Convert String To Decimal
% numbytes=floor(length(stream)/8);
% diff_stream=length(stream)-numbytes*8;
% if diff_stream==0
%     matrix_code_decimal= zeros(numbytes+2,8);
% else
%     matrix_code_decimal= zeros(numbytes+3,8);
% end
% s=0;
% for count2=1:8:numbytes*8
%     s=s+1;
%     matrix_code_decimal(s,1)=bin2dec(stream(1,count2:count2+7));
% end
% if diff_stream~=0
%     s=s+1;
%     matrix_code_decimal(s,1)=bin2dec(stream(1,numbytes*8+1:length(stream)));
% end
% 
% %% Final Marker
% matrix_code_decimal(s+1,1)=255;
% matrix_code_decimal(s+2,1)=217;

%% Define Size Image
Y = dec2hex(row_padding,4);
X = dec2hex(col_padding,4);
header_file(1,164) = hex2dec(Y(1,1:2));% vi tri 255 192 0 11 Y Y X X
header_file(1,165) = hex2dec(Y(1,3:4));
header_file(1,166) = hex2dec(X(1,1:2));
header_file(1,167) = hex2dec(X(1,3:4));
%% Concatenate Coding + Header
JP_STREAM(1,1:size(header_file,2))=header_file(1,1:size(header_file,2));
for j=1:1:size(matrix_code_decimal,1)
    JP_STREAM(1,size(header_file,2)+j)=matrix_code_decimal(j,1);
end
%% JPG Data Store
 
 %jpgdatastore_logfile(img_in);
   JP_STREAM=JP_STREAM';
   
   fid = fopen([img_name '.jpg'], 'wb');
   if fid < 0
      error('Failed to open data file for write');
   end
   fwrite(fid,JP_STREAM,'uint8'); 
   fclose(fid);

%% EVALUATION METRIC
    % Convert padded image to uint8 format && Save image as JPEG file 
        image_reference = uint8(image_padded);
        grayimage       = rgb2gray(image_reference);
        % Save grayscale image as BMP
            imwrite(grayimage, 'grayimage.bmp');
            imwrite (grayimage, 'matlab_ref.jpg', 'jpg','Quality',QF);
        myim     = imread([img_name '.jpg']);
        matlabim = imread('matlab_ref.jpg');
    % CR - Compression Ratio
        % Read original image
            original_info      = dir('grayimage.bmp');
        % Compressed JPEG file
            compressed_info      = dir([img_name '.jpg']);
            compressed_imageInfo = imfinfo(img_name,'jpg');
            compressed_matlabref = dir('matlab_ref.jpg');
        % File sizes in bytes
            original_size   = original_info.bytes;
            compressed_size = compressed_info.bytes;
            compressed_matlabref_size = compressed_matlabref.bytes;
        % Compression ratio
            CR = original_size / compressed_size;
            CR_matlabref = original_size / compressed_matlabref_size;
        % Compute bits per pixel
            bpp = (compressed_size * 8) / (col_padding * row_padding);
            bpp_matlabref = (compressed_matlabref_size * 8) / (col_padding * row_padding);
        fprintf('Original size   : %.3f KB   ', original_size/1024);
        fprintf('Compressed size : %.3f KB\n', compressed_size/1024);
        fprintf('\nCompression Ratio = %.2f : 1\n', CR);
        fprintf('\nMatlabref Compression Ratio = %.2f : 1\n', CR_matlabref);
        fprintf('\nBit rate (bpp) = %.2f bits/pixel\n', bpp);
        fprintf('\nnMatlabref Bit rate (bpp) = %.2f bits/pixel\n', bpp_matlabref);
        % display multiple image
            imagelist = {image_reference grayimage myim matlabim};
            figure
            montage(imagelist,Size=[1 NaN],BackgroundColor="white")
    % means square error       
        original            = double( grayimage (:) );
        reconstructed       = double( myim     (:) );
        reconstruct_matlab  = double( matlabim  (:) );
        error               = ( original - reconstructed      ).^2;
        error_by_jpegmatlab = ( original - reconstruct_matlab ).^2;

        mse0           = mean(error(:));
        mse_matlab     = mean(error_by_jpegmatlab(:));  
    % PSNR
        psnr_value0    = 10 * log10( (255^2) / mse0       );
        psnr_matlab    = 10 * log10( (255^2) / mse_matlab );
    % SSIM
        ssimval_0      = ssim( myim,    grayimage);
        ssimval_matlab = ssim( matlabim, grayimage);
        
        fprintf("\n mse0 %.2f mse_matlab %.2f \n;" + ...
            " psnr_value0 %.2f psnr_matlab %.2f ;\n " + ...
            "ssim0 %.2f ssim_matlab %.2f \n" ...
            , mse0, mse_matlab, ...
            psnr_value0, psnr_matlab, ...
            ssimval_0, ssimval_matlab);
function jpgdatastore_logfile(img_in)
    fprintf("\nPLEASE INPUT LOGFILE TXT\n");
    filename_ = uigetfile('*.txt')   % your simulation output file
    img_name = regexp(img_in,'\.','split');
    img_name = img_name{1};
    fid = fopen([img_name '.jpg'], 'wb');
    if fid < 0
       error('Failed to open data file for write');
    end
    fid_ = fopen(filename_,'r');
    if fid_ < 0
        error('Failed to open logfile: %s', filename_);
    end
    data = [];
    
    prev = -1;   % store previous byte

    while ~feof(fid_)
        line = fgetl(fid_);

        % extract number after "byteout "
        token = regexp(line,'byteout\s+(\d+)','tokens');

        if ~isempty(token)
            val = str2double(token{1}{1});
            data(end+1) = val;

            % stop condition: last two bytes = 255 217
            if prev == 255 && val == 217
                break;
            end

            prev = val;
        end
    end
    
    data = data.';
    
    fclose(fid_);
    fwrite(fid,data,'uint8'); 

    fclose(fid);
 end

function value = huffman_dc(dc)

dc_huffman = {'00', '010', '011', '100', '101', '110', '1110', ...
              '11110', '111110', '1111110', '11111110', '111111110'};

if dc>=0
    if dc==0
        temp = dec2bin(dc,2);
    else
        temp = [dc_huffman{size(dec2bin(dc),2)+1} dec2bin(dc)];
    end
else
    C1=dec2bin(abs(dc));
    for j=1:size(C1,2)
        if C1(:,j)=='0'
            C1(:,j)='1';
        else
            C1(:,j)='0';
        end
    end
    temp = [dc_huffman{size(dec2bin(abs(dc)),2)+1} C1];
end
value=temp;

end

function value = huffman_ac(vector_zz)
value = [];
C=[];
empty=0;
EOB = '1010';
ZRL = '11111111001';
ac_huffman={
   '00'               '01'               '100'              '1011'             '11010'            '1111000'          '11111000'         '1111110110'       '1111111110000010' '1111111110000011';...
   '1100'             '11011'            '1111001'          '111110110'        '11111110110'      '1111111110000100' '1111111110000101' '1111111110000110' '1111111110000111' '1111111110001000';...
   '11100'            '11111001'         '1111110111'       '111111110100'     '1111111110001001' '1111111110001010' '1111111110001011' '1111111110001100' '1111111110001101' '1111111110001110';...
   '111010'           '111110111'        '111111110101'     '1111111110001111' '1111111110010000' '1111111110010001' '1111111110010010' '1111111110010011' '1111111110010100' '1111111110010101';...
   '111011'           '1111111000'       '1111111110010110' '1111111110010111' '1111111110011000' '1111111110011001' '1111111110011010' '1111111110011011' '1111111110011100' '1111111110011101';...
   '1111010'          '11111110111'      '1111111110011110' '1111111110011111' '1111111110100000' '1111111110100001' '1111111110100010' '1111111110100011' '1111111110100100' '1111111110100101';...
   '1111011'          '111111110110'     '1111111110100110' '1111111110100111' '1111111110101000' '1111111110101001' '1111111110101010' '1111111110101011' '1111111110101100' '1111111110101101';...
   '11111010'         '111111110111'     '1111111110101110' '1111111110101111' '1111111110110000' '1111111110110001' '1111111110110010' '1111111110110011' '1111111110110100' '1111111110110101';...
   '111111000'        '111111111000000'  '1111111110110110' '1111111110110111' '1111111110111000' '1111111110111001' '1111111110111010' '1111111110111011' '1111111110111100' '1111111110111101';...
   '111111001'        '1111111110111110' '1111111110111111' '1111111111000000' '1111111111000000' '1111111111000010' '1111111111000011' '1111111111000100' '1111111111000101' '1111111111000110';...
   '111111010'        '1111111111000111' '1111111111001000' '1111111111001001' '1111111111001010' '1111111111001011' '1111111111001100' '1111111111001101' '1111111111001110' '1111111111001111';...
   '1111111001'       '1111111111010000' '1111111111010001' '1111111111010010' '1111111111010011' '1111111111010100' '1111111111010101' '1111111111010110' '1111111111010111' '1111111111011000';...
   '1111111010'       '1111111111011001' '1111111111011010' '1111111111011011' '1111111111011100' '1111111111011101' '1111111111011110' '1111111111011111' '1111111111100000' '1111111111100001';...
   '11111111000'      '1111111111100010' '1111111111100011' '1111111111100100' '1111111111100101' '1111111111100110' '1111111111100111' '1111111111101000' '1111111111101001' '1111111111101010';...
   '1111111111101011' '1111111111101100' '1111111111101101' '1111111111101110' '1111111111101111' '1111111111110000' '1111111111110001' '1111111111110010' '1111111111110011' '1111111111110100';...
   '1111111111110101' '1111111111110110' '1111111111110111' '1111111111111000' '1111111111111001' '1111111111111010' '1111111111111011' '1111111111111100' '1111111111111101' '1111111111111110'
}; 
   for i=1:63
        if vector_zz(i) == 0
            if (i == 63)
                    % fprintf("\n EOB \n");
                value = [C EOB];
            end
            empty=empty+1;
        else
            for k = 1:5
                if ( empty > 15) 
                        % fprintf("\n ZRL \n");
                    C = [C ZRL ];  
                    empty = empty -16;
                end
            end
            if (vector_zz(i) > 0) % AC_value > 0
               
                  temp = [ac_huffman{empty+1, max(size(dec2bin(abs(vector_zz(i)))))} dec2bin(vector_zz(i))];
               
               C=[C temp];
                   % disp(vector_zz(i));
                   % disp(temp);
               empty=0;

            else 
               if (vector_zz(i) < 0) % AC_value < 0
                  C1=dec2bin(abs(vector_zz(i)));
                  for j=1:max(size(C1))
                     if C1(:,j)=='0'
                        C1(:,j)='1';
                     else
                        C1(:,j)='0';
                     end 
                   end
                   temp = [ac_huffman{empty+1, max(size(dec2bin(abs(vector_zz(i)))))} C1];
                   C=[C temp];
                       % disp(vector_zz(i));
                       % disp(temp);
                   empty=0;
               end
            end
        end
   end
   
end

function stream = huf(stream,dc_value,ac_value,numbblocks)
   dpcm(1,1)=dc_value(1,1);
   stream=cat(2,stream,huffman_dc(dpcm(1,1)),huffman_ac(ac_value(1,1:63)));
   for m=2:numbblocks
       dpcm(m,1)=dc_value(m,1)-dc_value(m-1,1);
       stream=cat(2,stream,huffman_dc(dpcm(m,1)),huffman_ac(ac_value(m,1:63)));
   end
end


function result = winnograd(data_array)
   result = zeros (8,8);

   for column = 1:8
      for i = 1:8
         y(i) =data_array(column,i);
      end
      c5 = 0.55;
      c6 = 0.38;
      c7 = 0.19;
      s5 = 0.83;
      s6 = 0.92;
      s7 = 0.98;
      sqrt8 = 1/sqrt(8);
      [x01,x71] = butterfly(y(1),y(8));
      [x11,x61] = butterfly(y(2),y(7));
      [x21,x51] = butterfly(y(3),y(6));
      [x31,x41] = butterfly(y(4),y(5));
      %stage 2
      [x02,x32] = butterfly(x01,x31);
      [x12,x22] = butterfly(x11,x21);

      xx1 = x41*c7;
      xx2 = x41*s7;
      yy1 = x71*c7;
      yy2 = x71*s7;

      x42 = xx1 + yy2;
      x72 = yy1 - xx2;

      x52 = x51*c5 + x61*s5;
      x62 = x61*c5 - x51*s5;
      %%stage 3
      [x03,x13] = butterfly(x02,x12);

      x23=x22*c6+x32*s6;
      x33=-x22*s6+x32*c6;

      [x43,x53] = butterfly(x42,x52);
      [x63,x73] = butterfly(x62,x72);

      x04 = x03 * sqrt8;
      x14 = x13 * sqrt8;
      x24 = x23/2;
      x34 = x33/2;
      x44 = x43/2;

      [x54,x64] = butterfly(x53,x63);
      x57 = (x54 * sqrt8);
      x65 = (x64 * sqrt8);

      x75 = - x73 / 2;

      temp = int16([x04, x44,x24,x57,x14,x65,x34,x75]);
      for i = 1:8
         result(column,i) = temp(i);
      end
      if (column == 1)
      end
    end
end
 
%  winnograd(data_array).'
% (winnograd(winnograd(data_array).')).';
function [out1,out2] = butterfly(a,b)
   out1 = a + b;
   out2 = a - b;
end

function write_rgb24_to_coe(filename, RGB24)
% WRITE_RGB24_TO_COE  Generate .coe file from RGB24 (depth x 24 characters)
%
%   RGB24 must be a char matrix:
%       each row = "RRRRRRRR GGGGGGGG BBBBBBBB"
%
%   Example: write_rgb24_to_coe('output.coe', RGB24);

    fid = fopen(filename, 'w');
    if fid == -1
        error('Cannot open file: %s', filename);
    end

    % Header
    fprintf(fid, 'memory_initialization_radix=2;\n');
    fprintf(fid, 'memory_initialization_vector=\n');

    depth = size(RGB24, 1);

    % Write each row
    for i = 1:depth
        if i < depth
            fprintf(fid, '%s,\n', RGB24(i, :));
        else
            fprintf(fid, '%s;\n', RGB24(i, :));   % last line ends with ;
        end
    end

    fclose(fid);
end

