Object = require('classic')

DataFrame = Object:extend()

function DataFrame:new(file, delimiter)
    self.df = {}
    for line in io.lines(file) do
        local temp = {}
        for cell in string.gmatch(line,'([^,]+)') do table.insert(temp, cell)end
        table.insert(self.df, temp)
    end
end

function DataFrame:rows() return self.df end

function DataFrame:columns() return self.df end

    
    

