function enhancedImage = ACHME(inputImage, blockSize)
    % Get the dimensions of the input image
    [rows, cols, channels] = size(inputImage);

    % Initialize the output enhanced image
    enhancedImage = zeros(rows, cols, channels);

    % Iterate through the image in non-overlapping blocks of size blockSize
    for c = 1:channels
        for i = 1:blockSize:rows
            for j = 1:blockSize:cols
                % Define the current block for the current color channel
                block = inputImage(i:min(i+blockSize-1, rows), j:min(j+blockSize-1, cols), c);

                % Apply histogram equalization to the current block
                enhancedBlock = histeq(block);

                % Place the enhanced block in the output image
                enhancedImage(i:min(i+blockSize-1, rows), j:min(j+blockSize-1, cols), c) = enhancedBlock;
            end
        end
    end

    % Convert the output enhanced image to uint8 format (0-255)
    enhancedImage = double(enhancedImage);
end