classdef Combination < handle
    %COMBINATION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        storage
    end
    
    methods
        function setup(self, data)
            self.storage = Storage(data);
            self.storage.setSubdir('combination');
        end
        
        function setSlice(self, iSlice)
            self.storage.setSlice(iSlice);
        end
    end
    
end

