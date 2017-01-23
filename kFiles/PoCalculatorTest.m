classdef PoCalculatorTest < matlab.unittest.TestCase
    
    properties
    end
    
    methods (Test)
        function testCreateAspirePo(testCase)
            poCalculator = AspirePoCalculator;
            
            testCase.verifyTrue(isvalid(poCalculator));
        end
        
        function testAspirePoCalculation(testCase)
            s = [2 3 1 5 6];
            sigma = 5;
            compl = rand(s) + 1i*rand(s);
            
            poCalculator = AspirePoCalculator;
            poCalculator.calculatePo(compl);
            poCalculator.smoothPo(sigma);
            removedPo = poCalculator.removePo(compl);
            
            testCase.verifyEqual(size(removedPo), size(compl));
        end
    end
    
end

