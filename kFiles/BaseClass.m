classdef (Abstract) BaseClass < handle
   
properties
    smoother
    storage
end

methods
    function checkRestrictions(self, data) %#ok<INUSD>
    end
    
    function setup(self, data)
        self.storage = Storage(data);
        self.storage.setSubdir('steps');
        self.smoother = data.smoother;
        self.smoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d, self.storage);
    end
    
    function setSlice(self, slice)
        self.storage.setSlice(slice);
    end
    
end

end
