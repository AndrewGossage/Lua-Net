local Object = require('classic')
require('DataFrame')


function dot(x,y)
    sum = 0
    for i = 1, #x do sum = sum + (x[i] * y[i]) end

    return sum
end

function relu(x)
    local out = {}
    for i = 1, #x do
        table.insert(math.max(x[i],0))
    end
    return out
end
function absoluteError(x,y)

    local sum = 0
    for i = 1, #x do
        sum = sum + math.abs(x[i] - y[i])
    end
    return sum
end

function meanAbsoluteError(x,y)
    local out = {}
    for i= 1, #x do
        table.insert(out, absoluteError(x[i], y[i]))
    end
    local sum = 0
    for i= 1, #out do
        sum = sum + out[i]
    end
    return sum / #out
end
    

x = DataFrame('input.csv',','):rows()
y = DataFrame('target.csv',','):rows()
table.remove(y,1)





Neuron = Object:extend()
function Neuron:new(size)
    self.weights = {}
    for i = 1, size do
        table.insert(self.weights, math.random(0, 200) / 100) 
    end
    self.bias =  math.random(0, 200) / 100
end

function Neuron:copy()
    local other = Neuron(#self.weights)
    for i = 1, #self.weights do
        other.weights[i] = self.weights[i]
    end
    other.bias = self.bias
    return other
end

function Neuron:__tostring()
    local w = "Weights: ["
    for i=1, #self.weights do
        w = w ..  self.weights[i] .. ' '
    end
    w = w ..  '] '
  return  w .. "Bias: " .. self.bias
end

Layer = Object:extend()

function Layer:new(inputs, neurons)
    self.n = {}
    for i =1, neurons do
        table.insert(self.n,Neuron(inputs))
    end
end

function Layer:copy()
    local other = Layer(#self.n[1].weights, #self.n)
    for i =1, #self.n do
         other.n[i] = self.n[i]:copy()
    end
    return other
end

function Layer:__tostring()
    local w = "Layer: "
    for i=1, #self.n do
        w = w .. self.n[i]
    end
  return  w
end

function Layer:print()
    local w = "Layer: "
    for i=1, #self.n do
        print(self.n[i])
    end
end


layer = Layer(4,2)



FeedForward = Object:extend()
function FeedForward:new(inputs, layers )
    self.act = relu
    self.l = {}
    table.insert(self.l, Layer(inputs, layers[1]))
    for i = 2, #layers do
        table.insert(self.l, Layer(#self.l[i-1].n, layers[i]))
    end
    self.history = {self.l}
    
end

function FeedForward:copy_net(l)
    local other = {}
    for i = 1, #l do
        table.insert(other, l[i]:copy()) 
    end
    return other
end  

function FeedForward:print()
    for i=1, #self.l do
        print("Layer: " .. i)
        self.l[i]:print()
        print('\n')
    end
end

function FeedForward:runLayer(layer, inputs)
    local out = {}
    for i = 1, #layer.n do
        table.insert(out, dot(layer.n[1].weights, inputs))
    end
    return out
end

function FeedForward:forward(inputs)
    local out = {}
    for j=1, #inputs do
        local feed = inputs[j]
        for i =1, #self.l do

            feed = self:runLayer(self.l[i], feed)

        end
        table.insert(out, feed)
    end
    return out
end



function FeedForward:update(x,y)
    local mae = meanAbsoluteError(x,y)
    for i = 1, #self.l do
        for j = 1, #self.l[i].n do
            for k = 1, #self.l[i].n[j].weights do
                self.l[i].n[j].weights[k] = self.l[i].n[j].weights[k] + (math.random(-100,100) / 100) * mae
            end
        end
    end
end 

function FeedForward:train(x,y, iters)
    local mae = meanAbsoluteError(self:forward(x),y)
    print(mae)
    
    local best = self:copy_net(self.l)
    for i = 1, iters do
        
        self:update(self:forward(x),y)
        if meanAbsoluteError(self:forward(x),y) < mae then
            mae = meanAbsoluteError(self:forward(x),y)
            print('Improved iter = ' .. i.. ' MAE = ' .. mae)
            best = self:copy_net(self.l)
            table.insert(self.history, self.l)
        else
            
            self.l = self:copy_net(best)
        end
        
        
    end
    print(meanAbsoluteError(self:forward(x),y))
end
    

















