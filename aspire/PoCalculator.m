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
    function checkRestrictions(self, data) %#ok<INUSD>
    end
    
    function setup(self, data)
        self.storage = Storage(data);
        self.storage.setSubdir('poCalculation');
        self.smoother = data.smoother;
        self.smoother.setup(data.smoothingSigmaSizeInVoxel, data.weighted_smoothing, data.smooth3d, self.storage);
    end
    
    function iterativeCorrection(~, ~)
    end
    
    function preprocess(self) %#ok<MANU>
    end
    
    function setSlice(self, slice)
        self.storage.setSlice(slice);
    end
    
    % TODO: does it make sense?
    function removeLowSens(self)
        threshold = 0.01;
        pSum = sum(abs(self.po), 5);
        remove = pSum < threshold * max(pSum(:));
        remove = repmat(remove, [1 1 1 1 size(self.po, 5)]);
        self.po(remove) = 0;
        
%         for iCha = 1:size(self.po, 4)
%             p = self.po(:,:,:,1,iCha);
%             p(abs(p) < threshold * max(abs(p(:)))) = 0; 
%             self.po(:,:,:,1,iCha) = p;
%         end
    end
    
    function compl = removePo(self, compl)
        nEchoes = size(compl,4);
        for eco = 1:nEchoes
            compl(:,:,:,eco,:) = compl(:,:,:,eco,:) .* exp(-1i * angle(self.po));
        end
    end

    function smoothPo(self, compl)
        weight = sum(abs(compl), 5);
        self.po = self.smoother.smooth(self.po, weight);
    end

    function setSens(self, compl)
        if isempty(self.po)
            self.po = ones(size(compl, 1), size(compl, 2), size(compl, 3), 1, size(compl,5));
        end
        for iCha = 1:size(self.po, 4) % for RAM saving
            self.po(:,:,:,1,iCha) = exp(1i * angle(self.po(:,:,:,1,iCha))) .* abs(compl(:,:,:,1,iCha));
        end
    end
    
    function sens = getSens(self)
        sens = abs(self.po);
    end
    
    function sens = getSensPo(self)
        sens = self.po;
    end
    % deprecated
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

        po = complex(zeros([size_compl(1:3) 1 nChannels], 'single'));
        for iCha = 1:nChannels
            po_double = double(compl(:,:,:,echo,iCha)) .* double(conj(hip));
            po(:,:,:,1,iCha) = single(po_double);
        end
    end
end

end
