classdef WriterTest < matlab.unittest.TestCase
    
    methods (Test)
        
        function testIfFileWasSaved(testCase)
            imageDims = [1 1 1];
            
            data.save_steps = 'results';
            data.processing_option = 'all_at_once';
            data.write_dir = '~/data/aspireTTD';
            data.nii_pixdim = [3 imageDims];
            data.slices = 1;
            
            sliceNumber = 1;
            subdir = 'results';
            image = ones(imageDims);
            name = 'testImage';
            
            writer = Writer(data);
            writer.write(sliceNumber, subdir, image, name);
            
            testCase.verifyTrue(exist('~/data/aspireTTD/testImage.nii', 'file'));
            
            delete('~/data/aspireTTD/testImage.nii');
        end
    end
    
end

