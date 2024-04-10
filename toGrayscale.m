function returnedImage = toGrayscale(image)
        i = image;
        R = i(:, :, 1);
        G = i(:, :, 2);
        B = i(:, :, 3);
        newImage = zeros(size(i,1), size(i,2), 'uint8');
        
        for x=1:size(i,1)
           for y=1:size(i,2)
               newImage(x,y) = (R(x,y)*.299)+(G(x,y)*.587)+(B(x,y)*.114);
           end
        end
        
        returnedImage = newImage;
end
