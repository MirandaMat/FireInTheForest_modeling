-- Imports

import("sysdyn")
import("calibration")

-- Seed
Random{seed = 70374981}

-- Model
Fire = Model{
    dim = 50, -- Map dimensions
    empty = 0.2, -- Percentage of non-forested areas
    finalTime = 100, -- Number of time
    init = function(model)
        model.cell = Cell{
            -- Initializes empty randomly
            state = Random{forest = 1 - model.empty, empty = model.empty},
            -- It makes state transitions
            execute = function(cell)
                -- Verify the closest neighbor of the forest cell is burning
                if cell.state == "burning" then
                    cell.state = "burned"
                elseif cell.state == "forest" then
                    forEachNeighbor(cell, function(neighbor)
                        if neighbor.past.state == "burning" then
                            cell.state = "burning"
                            -- Stops scrolling through the other neighbors
                            return false
                        end
                    end)
                end
            end
        }
        -- Cellular space
        model.cs = CellularSpace{
            xdim = model.dim, -- Get the map dimensions
            instance = model.cell -- Define cells instances
        }

        -- Initializes burn cell randomly
        model.cs:sample().state = "burning"
        -- model.cs:get(1,1).state = "burning"

        -- Select the neighbors settings (Moore or Vonneumann)
        --model.cs:createNeighborhood{} -- Moore
        model.cs:createNeighborhood{strategy = "vonneumann"} -- Vonneumann

        -- Map settings
        model.map = Map{
            target = model.cs,
            select = "state",
            value = {"forest", "burning", "burned", "empty"},
            grid = true,
            color = {"green", "red", "gray", "brown"}
        }

        -- Define the time of events
        model.timer = Timer{
            -- Run the map interations
            Event{action = model.map},
            -- Run the cellular space
            Event{action = model.cs},
            -- Events Time
            Event{start = 100, period = 10,  action = function()
                    -- Split the CellularSpace into a table of Trajectories
                    -- according to state burning
                    local burning = model.cs:split("state").burning
                    -- The event is interrupted if burning is nil
                    if burning == nil then
                        model.timer:clear()
                        return false
                    end
            end}
        }
    end
}


-- Multiple runs
local m = MultipleRuns{
	model = Fire, -- Select the model
	repetition = 50, -- Number of simulation
	parameters = {
        -- Empty state variation scale
		empty = Choice{min = 0.0, max = 1.0, step = 0.01},
        -- Set a new Map dimension
		dim = 100
	},
    -- Return the number of times for each state
	forest = function(model)
		return model.cs:state().forest or 0
	end,
	burned = function(model)
		return model.cs:state().burned or 0
	end,
    eob = function(model)
        return model.endOfBurning
    end,

	summary = function(result)
        local sum = 0
        local simulation_time = 0
        local max = -math.huge
        local min = math.huge

        -- Get runtime
        forEachElement(result.eob, function(_, value)
           simulation_time = simulation_time + value
        end)

        simulation_time = simulation_time / #result.eob

        -- Get cells neighboors with forest
        forEachElement(result.forest, function(_, value)
            sum = sum + value

            if max < value then
                max = value
            end

            if min > value then
                min = value
            end
        end)

        return {
            average = sum / #result.forest,
            simulation_time = simulation_time,
            max = max,
            min = min
        }
    end
}

-- Define files names
file = File("resultado.csv") -- resultado de cada uma das simulacoes
file:write(m.output, ";")

file = File("resultado-medias.csv") -- resultado agregado das repeticoes
file:write(m.summary, ";")

-- Average of the results
local sum = 0
forEachElement(m.output, function(_, value)
	sum = sum + value.forest
end)

average = sum / #m.output

print("Average forest in the end of "..#m.output.." simulations: "..average)

m.summary.expected = {}
forEachElement(m.summary, function(_, result)
	table.insert(m.summary.expected, result.dim * result.dim * (1-result.empty))
end)

-- Plot the Graph
c = Chart{
    target = m.summary,
    select = {"average", "expected"},
    xAxis = "empty",
	color = {"red", "green"}
}

c:save("resultado.png")

Chart{
    target = m.summary,
    select = "simulation_time",
    xAxis = "empty"
}