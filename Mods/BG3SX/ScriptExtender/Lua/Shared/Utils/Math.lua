Math = {}
Math.__index = Math

function Math:DegreeToRadian(deg)
    return deg * (math.pi/180)
end