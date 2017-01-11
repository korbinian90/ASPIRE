classdef WriterTest < matlab.unittest.TestCase
    
    properties (Access = private)
        writer
        name
        filePath
        image
        writeDir
        d
    end
    
    methods (TestMethodSetup)
        function setupData(testCase)
            data.imageDims = [2 3 4 5];
            data.save_steps = 0;
            data.processing_option = 'all_at_once';
            data.write_dir = '~/data/aspireTTD';
            data.nii_pixdim = [length(data.imageDims) data.imageDims];
            data.slices = 1;
            
            testCase.name = 'testImage';
            subdir = 'results';
            testCase.filePath = fullfile(data.write_dir, subdir, [testCase.name '.nii']);
            if exist(testCase.filePath, 'file')
                delete(testCase.filePath);
            end
            
            testCase.image = rand(data.imageDims);
            testCase.writer = Writer(data);
            testCase.writer.setSubDir(subdir);
            testCase.writeDir = data.write_dir;
            testCase.d = data;
        end
    end
    
    methods (Test)
        function testIfRetrievedFileMatchesOriginal(testCase)
            
            testCase.writer.write(testCase.image, testCase.name);
            nii = load_nii(testCase.filePath);
            testCase.verifyEqual(nii.img, testCase.image);
            
        end
        
        function testNonSavedSubdir(testCase)
            
            subdir = 'steps';
            
            file = fullfile(testCase.writeDir, subdir, [testCase.name '.nii']);
            if exist(file, 'file')
                delete(file);
            end
            
            testCase.writer.setSubDir(subdir);
            testCase.writer.write(testCase.image, testCase.name);
            
            testCase.verifyEqual(exist(file, 'file'), 0);
        end
        
        function testWriteOnlySomeChannels(testCase)
            
            channels = [1 4];
            testCase.writer.write(testCase.image, testCase.name, channels);
            
            nii = load_nii(testCase.filePath);
            
            testCase.verifyEqual(nii.img, testCase.image(:,:,:,channels));
        end
        
        function testSavePhaseIfImageIsComplex(testCase)
            
            complexImage = exp(1i * testCase.image);
            
            testCase.writer.write(complexImage, testCase.name);
            nii = load_nii(testCase.filePath);
            testCase.verifyEqual(nii.img, angle(complexImage));
        end
        
        function testWriteSliceBySlice(testCase)
            data = testCase.d;
            data.processing_option = 'slice_by_slice';
            
            sliceNumber = 4;
            [path, fileName] = fileparts(testCase.filePath);
            fileName = [fullfile(path, fileName) '_4.nii'];
            
            sliceWriter = Writer(data);
            sliceWriter.setSubDir('results');
            sliceWriter.setSlice(sliceNumber);
            sliceWriter.write(testCase.image, testCase.name);
            nii = load_nii(fileName);
            testCase.verifyEqual(nii.img, testCase.image);
        end
        
        function test5DSepChannel(testCase)
            
            image5D = rand([2 3 4 5 6]);
            channels = 1:2;
            testCase.writer.write(image5D, testCase.name, channels);
            
            [path, fileName] = fileparts(testCase.filePath);
            fileName1 = [fullfile(path, fileName) '_c1.nii'];
            fileName2 = [fullfile(path, fileName) '_c2.nii'];
            
            nii_c1 = load_nii(fileName1);
            nii_c2 = load_nii(fileName2);
            
            testCase.verifyEqual(nii_c1.img, image5D(:,:,:,:,1));
            testCase.verifyEqual(nii_c2.img, image5D(:,:,:,:,2));
        end
        
%         function test5DSepChannelSlicewise(testCase)
%             
%             image5D = rand([2 3 4 5 6]);
%             channels = 1:2;
%             testCase.writer.write(image5D, testCase.name, channels);
%             
%             [path, fileName] = fileparts(testCase.filePath);
%             fileName1 = [fullfile(path, fileName) '_c1.nii'];
%             fileName2 = [fullfile(path, fileName) '_c2.nii'];
%             
%             nii_c1 = load_nii(fileName1);
%             nii_c2 = load_nii(fileName2);
%             
%             testCase.verifyEqual(nii_c1.img, image5D(:,:,:,:,1));
%             testCase.verifyEqual(nii_c2.img, image5D(:,:,:,:,2));
%         end
    end
    
end

