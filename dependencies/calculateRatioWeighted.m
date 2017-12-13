function ratio = calculateRatioWeighted(combinedMagnitude, magnitude, sensitivity)
    
    weightedMagnitudeSum = weightedCombinationAspire(magnitude, sensitivity);
    ratio = combinedMagnitude ./ weightedMagnitudeSum;
    
end