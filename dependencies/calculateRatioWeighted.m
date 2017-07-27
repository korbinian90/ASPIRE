function ratio = calculateRatioWeighted(combinedMagnitude, magnitude, sensitivity)
    
    weightedMagnitudeSum = weightedCombination(magnitude, sensitivity);
    ratio = combinedMagnitude ./ weightedMagnitudeSum;
    
end