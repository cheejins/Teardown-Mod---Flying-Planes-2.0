Projectiles = {}


function createProjectile(transform, projectiles, projPreset, ignoreBodies, homingShape) --- Instantiates a proj and adds it to the projectiles table.

    local proj = DeepCopy(projPreset)
    proj.ignoreBodies = DeepCopy(ignoreBodies)

    proj.transform = transform
    local trDir = QuatToDir(proj.transform.rot)
    trDir = VecNormalize(VecAdd(trDir, VecRdm(proj.spread)))
    proj.transform.rot = DirToQuat(trDir)

    if proj.homing.max > 0 and homingShape ~= nil then
        proj.homing.targetShape = homingShape
        proj.homing.targetPos = GetShapeLocalTransform(homingShape).pos
    end

    table.insert(projectiles, proj)

end

function manageActiveProjectiles()

    local projectilesToRemove = {} -- projectiles iterations.
    for i, proj in ipairs(Projectiles) do

        if proj.isActive and proj.hit == false then

            propelProjectile(proj)

        elseif proj.isActive == false or proj.hit then -- if proj is inactive.

            table.insert(projectilesToRemove, i)

        end

    end

    for i = 1, #projectilesToRemove do -- remove proj from active projs after projectiles iterations.
        table.remove(Projectiles, projectilesToRemove[i]) -- remove active projs
    end

end

function propelProjectile(proj)

    --+ Move proj forward.
    proj.transform.pos = TransformToParentPoint(proj.transform, Vec(0,0,-proj.speed))

    proj.lifeLength = proj.lifeLength - GetTimeStep()
    if proj.lifeLength <= 0 then
        proj.hit = true
    end

    --+ Ignore bodies
    if proj.ignoreBodies ~= nil then
        for i = 1, #proj.ignoreBodies do
            QueryRejectBody(proj.ignoreBodies[i])
        end
    end

    --+ Raycast
    local rcHit, hitPos, hitShape = RaycastFromTransform(proj.transform, proj.speed, proj.rcRad, proj.ignoreBodies, nil, true)
    if rcHit and not proj.hitInitial then

        proj.hitInitial = true
        proj.hit = true

        --+ Hit Action
        -- ApplyBodyImpulse(GetShapeBody(hitShape), hitPos, VecScale(QuatToDir(proj.transform.rot), proj.force))

        if proj.explosionSize > 0 then
            Explosion(hitPos, proj.explosionSize)
        end

        --+ Sounds
        -- local index = proj.sounds.hit[math.random(1, #proj.sounds.hit)]
        -- PlayRandomSound(proj.sounds.hit, proj.transform.pos, 2, index)
        -- PlayRandomSound(proj.sounds.hit, GetCameraTransform().pos, 0.2 + math.random()/10, index)

    end

    -- if proj.penetrate then

    --     proj.hit = false

    --     if VecDist(robot.transform.pos, proj.transform.pos) > proj.holeSize * 2 then
    --         MakeHole(proj.transform.pos, proj.holeSize,proj.holeSize,proj.holeSize,proj.holeSize)
    --     end

    -- end

    --+ Proj hit water.
    if IsPointInWater(proj.transform.pos) then
        proj.hit = true
        SpawnParticle("water", proj.transform.pos, Vec(0,0,0))
    end

    --+ Proj life.
    if proj.hit then
        proj.isActive = false
    else
        proj.isActive = true
    end


    --+ Proj homing.
    if proj.homing.max > 0 and proj.homing.targetShape ~= nil then

        local b = GetShapeBody(proj.homing.targetShape)
        proj.homing.targetPos = AabbGetBodyCenterPos(b)
        -- proj.homing.targetPos = GetBodyTransform(b).pos

        dbl(proj.transform.pos, proj.homing.targetPos, 1,0,1, 1)
        dbray(proj.transform, 30, 0,1,1, 1)

        proj.transform.rot = MakeQuaternion(proj.transform.rot)
        proj.transform.rot = proj.transform.rot:Approach(QuatLookAt(proj.transform.pos, proj.homing.targetPos), proj.homing.force) -- Rotate towards homing target.

        if proj.homing.force < proj.homing.max then -- Increment homing strength.
            proj.homing.force = proj.homing.force + proj.homing.gain
        end

    end


    --+ Draw sprite
    if proj.effects.sprite_facePlayer then
        DrawSprite(LoadSprite(proj.effects.sprite), Transform(proj.transform.pos, QuatLookAt(proj.transform.pos, GetCameraTransform().pos)), proj.effects.sprite_dimensions[1], proj.effects.sprite_dimensions[2], 1, 1, 1, 1, true)
    else
        DrawSprite(LoadSprite(proj.effects.sprite), Transform(proj.transform.pos, QuatRotateQuat(proj.transform.rot, QuatEuler(90,-90,0))), proj.effects.sprite_dimensions[1], proj.effects.sprite_dimensions[2], 1, 1, 1, 1, true)
        DrawSprite(LoadSprite(proj.effects.sprite), Transform(proj.transform.pos, QuatRotateQuat(proj.transform.rot, QuatEuler(0,-90,0))), proj.effects.sprite_dimensions[1], proj.effects.sprite_dimensions[2], 1, 1, 1, 1, true)
    end


    --+ Particles
    if proj.category == 'missile' then
        SpawnParticle("fire", proj.transform.pos, Vec(0,0,0), 1.5, 0.2)
        SpawnParticle("smoke", proj.transform.pos, Vec(0,0,0), 0.8, 4)
    end


    local c = proj.effects.color
    PointLight(proj.transform.pos, c[1], c[2], c[3], 1)

end

function initProjectiles()

    ProjectilePresets = {

        bullets = {

            standard = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 3, --Seconds

                category = 'bullet',

                speed = 6,
                spread = 0.005,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 0.5,
                rcRad = 0.2,
                force = 0,
                penetrate = false,
                holeSize = 1,

                effects = {
                    -- particle = 'aeon_secondary',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/script/img/bullet1.png',
                    sprite_dimensions = {7, 1},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0,
                    gain = 0,
                    max = 0,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            },

            emg = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 3, --Seconds

                category = 'bullet',

                speed = 6,
                spread = 0.01,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 1.5,
                rcRad = 0.2,
                force = 0,
                penetrate = false,
                holeSize = 1,

                effects = {
                    -- particle = 'aeon_secondary',
                    color = Vec(1,0,0),
                    sprite = 'MOD/script/img/bullet_emg.png',
                    sprite_dimensions = {9, 1.5},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0,
                    gain = 0,
                    max = 0,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            }

        },

        missiles = {

            standard = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 3, --Seconds

                category = 'missile',

                speed = 3,
                spread = 0,
                drop = 0,
                dropIncrement = 0,
                explosionSize = 3.5,
                rcRad = 0.3,
                force = 0,
                penetrate = false,
                holeSize = 0,

                effects = {
                    particle = 'smoke',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/script/img/missile1.png',
                    sprite_dimensions = {5, 2},
                    sprite_facePlayer = false,
                },

                sounds = {
                    -- hit = Sounds.weap_secondary.hit,
                    hit_vol = 5,
                },

                homing = {
                    force = 0.01,
                    gain = 0,
                    max = 10,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }
            }

        },

        bombs = {

            standard = {

                isActive = true, -- Active when firing, inactive after hit.
                hit = false,
                hitInitial = false,
                lifeLength = 15, --Seconds

                category = 'bomb',

                speed = 0.55,
                spread = 0.22,
                drop = 0.25,
                dropIncrement = 0,
                explosionSize = 4,
                rcRad = 0.3,
                force = 0,
                penetrate = false,
                holeSize = 0,

                effects = {
                    particle = 'smoke',
                    color = Vec(1,0.5,0.3),
                    sprite = 'MOD/script/img/bomb1.png',
                    sprite_dimensions = {2, 1},
                    sprite_facePlayer = false,
                },

                homing = {
                    force = 0,
                    gain = 0,
                    max = 0,
                    targetShape = nil,
                    targetPos = Vec(),
                    targetPosRadius = 0,
                }

        }
    }

    }

end
