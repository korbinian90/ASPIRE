function ratio = calculateRatioWeightedAspire(combinedMagnitude, magnitude, sensitivity)
    
    weightedMagnitudeSum = weightedCombinationAspire(magnitude, sensitivity);
    ratio = combinedMagnitude ./ weightedMagnitudeSum;
    
end