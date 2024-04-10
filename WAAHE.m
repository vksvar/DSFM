function enhancedImage = WAAHE(inputImage, windowSize, alpha)
    % Get the dimensions of the input image
    [rows, cols, channels] = size(inputImage);

    % Initialize the output enhanced image
    enhancedImage = zeros(rows, cols, channels);

    % Calculate half of the window size
    halfWindowSize = floor(windowSize / 2);

    for c = 1:channels
        for i = 1:rows
            for j = 1:cols
                % Define the neighborhood window for the current pixel
                rowStart = max(1, i - halfWindowSize);
                rowEnd = min(rows, i + halfWindowSize);
                colStart = max(1, j - halfWindowSize);
                colEnd = min(cols, j + halfWindowSize);

                % Extract the local window for the current channel
                localWindow = inputImage(rowStart:rowEnd, colStart:colEnd, c);

                % Calculate the mean and standard deviation of the local window
                localMean = mean(localWindow(:));
                localStd = std(double(localWindow(:)));

                % Calculate the weight for the current pixel in the current channel
                weight = 1 + alpha * ((inputImage(i, j, c) - localMean) / (localStd + 1e-5));

                % Apply weighted histogram equalization to the current pixel in the current channel
                enhancedImage(i, j, c) = weight * inputImage(i, j, c);
            end
        end
    end

    % Convert the output enhanced image to uint8 format (0-255)
    enhancedImage = uint8(enhancedImage);
end
