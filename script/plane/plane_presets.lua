function plane_AutoConvertToPreset(plane)

    if plane.model == "spitfire" then
        convertPlaneToSpitfire(plane)
    elseif plane.model == "a10" then
        convertPlaneToA10(plane)
    elseif plane.model == "bombardierJet" then
        convertPlaneToBombardierJet(plane)
    elseif plane.model == "cessna172" then
        convertPlaneToCessna172(plane)
    elseif plane.model == "ac130" then
        convertPlaneToAC130(plane)
    elseif plane.model == "b2" then
        convertPlaneToB2(plane)
    end

end


function convertPlaneToSpitfire(plane)
    plane.topSpeed = 70
    plane.thrustImpulseAmount = 20
    plane.engineVol = 1

    plane.pitchVal = 1
    plane.rollVal = 1
    plane.yawFac = 1

    plane.seatPosOffset = Vec(0,0,-12)
    plane.brakeImpulseAmt = 300

    plane.gunPosOffset = Vec(-1.7, -0.2, -15)
    plane.gunPosOffset2 = Vec(1.7, -0.2, -15) -- opposite wing mg

    plane.bullets.type = "mg"
    plane.bullets.rpm = 1400

    plane.camBack = 10
    plane.camUp = 5
    plane.camPitch = -7
end


function convertPlaneToA10(plane)
    plane.topSpeed = 130
    plane.thrustImpulseAmount = 120
    plane.engineVol = 1

    plane.pitchVal = 0.8
    plane.rollVal = 0.8
    plane.yawFac = 0.8

    plane.seatPosOffset = Vec(0,0,-12)
    plane.camPullUp = 9

    plane.gunPosOffset = Vec(0,-0.2,-15)
    plane.missiles.rpm = 50
    plane.bullets.type = "emg"
    plane.bullets.rpm = 600
end


function convertPlaneToBombardierJet(plane)
    plane.isArmed = false

    plane.topSpeed = 130
    plane.thrustImpulseAmount = 150
    plane.engineVol = 1

    plane.pitchVal = 1
    plane.rollVal = 2
    plane.yawFac = 2

    plane.camBack = 45
    plane.camUp = 15
    plane.camPitch = 0
end

function convertPlaneToCessna172(plane)
    plane.isArmed = true

    plane.gunPosOffset = Vec(-2.5, 0, -12)
    plane.gunPosOffset2 = Vec(2.5, 0, -12) -- opposite wing mg

    plane.topSpeed = 140
    plane.thrustImpulseAmount = 30
    plane.engineVol = 1

    plane.pitchVal = 1
    plane.rollVal = 1
    plane.yawFac = 1

    plane.camBack = 45
    plane.camUp = 15
    plane.camPitch = 0
end

function convertPlaneToAC130(plane)
    plane.isArmed = false

    plane.topSpeed = 130
    plane.thrustImpulseAmount = 600
    plane.engineVol = 1

    plane.brakeImpulseAmt = 500

    plane.pitchVal = 2
    plane.rollVal = 3
    plane.yawFac = 3

    plane.camBack = 45
    plane.camUp = 15
    plane.camPitch = 0
end

function convertPlaneToB2(plane)
    plane.isArmed = true

    plane.topSpeed = 120
    plane.thrustImpulseAmount = 300
    plane.engineVol = 1

    plane.brakeImpulseAmt = 400

    plane.pitchVal = 3
    plane.rollVal = 3
    plane.yawFac = 3

    plane.camBack = 45
    plane.camUp = 15
    plane.camPitch = 0
end