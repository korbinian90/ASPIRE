classdef (Abstract) PoCalculator < handle
   
properties
    po
    smoother
    storage
end

methods (Abstract)
    calculatePo(self, compl)
end

methods
    function setup(self, data)
        self.storage = Storage(data);
        self.storage.setSubdir('poCalculation');
        self.smoother = data.smoother;
        self.smoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d);
    end
    
    function iterativeCorrection(~, ~)
    end
    
    function preprocess(~)
    end
    
    function setSlice(self, slice)
        self.storage.setSlice(slice);
    end
    
    function compl = removePo(self, compl)
        nEchoes = size(compl,4);
        for eco = 1:nEchoes
            compl(:,:,:,eco,:) = squeeze(compl(:,:,:,eco,:)) .* squeeze(conj(self.po));
        end
    end

    function smoothPo(self, weight)
        self.po = self.smoother.smooth(self.po, weight);
    end

    function removeMagPo(self)
        self.po = self.removeMag(self.po);
    end
end

methods (Static)
    
    function po = removeMag(po)
        po = exp(1i * angle(po));
    end
    
    function compl = normalize(compl)
        compl = compl ./ sqrt(abs(compl));
        compl(~isfinite(compl)) = 0;
    end
    
    function po = subtractFromEcho(compl, hip, echo)
        nChannels = size(compl, 5);
        size_compl = size(compl);

        po = complex(zeros([size_compl(1:3) nChannels], 'single'));
        for iCha = 1:nChannels
            po_double = double(compl(:,:,:,echo,iCha)) .* double(conj(hip));
            po(:,:,:,iCha) = single(po_double);
        end
    end
end

end

