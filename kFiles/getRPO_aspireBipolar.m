function rpo = getRPO_aspireBipolar(compl)
%GETRPO_ASPIRE calculates the RPO using the aspire method
%   Detailed explanation goes here

    a12 = calculateAspirePo(compl, [1 2]);
    a23 = calculateAspirePo(compl, [2 3]);
    
    % only for 1st and 3rd echo
    rpo = (2 * a12) - a23;
    
end
