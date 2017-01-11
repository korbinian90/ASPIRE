function deleteIfExist( file )
    if exist(file, 'file')
        delete(file)
    end
end

