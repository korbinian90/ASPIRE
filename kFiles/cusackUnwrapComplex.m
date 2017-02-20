function unwrapped = cusackUnwrapComplex(compl)
    unwrapped = cusackUnwrap(angle(compl), abs(compl));
end

