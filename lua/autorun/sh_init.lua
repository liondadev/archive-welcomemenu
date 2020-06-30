
local client_menuScreenPos = Vector(-5720, -5503, -10462)
local client_menuScreenAng = Vector(15, 45, 0)

local sv_playerSpawnPos = Vector(207, -920, -12735)
local sv_playerSpawnAng = Angle(0, 107, 0)


if SERVER then
    AddCSLuaFile()

    print([[

        [MODULE] Loaded WelcomeMenu
    ]])

    hook.Add("PlayerInitialSpawn","FullLoadSetup",function(ply)
        hook.Add("SetupMove",ply,function(self,ply,_,cmd)
            if self == ply and not cmd:IsForced() then hook.Run("PlayerFullLoad",self) hook.Remove("SetupMove",self) end
        end)
    end)

    util.AddNetworkString("Module_OpenLoadMenuNet")

    hook.Add("PlayerFullLoad", "Module_OpenLoadMenu", function(ply)
        net.Start("Module_OpenLoadMenuNet", false)
        net.Send(ply)
    end)

    hook.Add("PlayerSpawn", "Module_PlayerSpawn", function(ply)
        timer.Simple(0.000005, function()
            ply:SetPos(sv_playerSpawnPos)
            ply:SetEyeAngles(sv_playerSpawnAng)
        end)
    end)


    -- Remove player colision, code by: https://garrysmods.org/download/55676
    hook.Add( "PlayerSpawn", "PlayerCollision", function(ply) ply:SetCollisionGroup(11) end )
end


if CLIENT then

    surface.CreateFont("Module_LoadMenu_Button", {
        font = "Arial",
        size = 50,
        weight = 500,
    })


    local function OpenLoadMenu()

        local function MyCalcView(ply, pos, angles, fov)
            local view = {}
            view.origin = client_menuScreenPos
            view.angles = client_menuScreenAng
            view.fov = fov
            view.drawviewer = true
        
            return view
        end
         
        hook.Add( "CalcView", "Module_LoadMenu_CamPos", MyCalcView )

        hook.Add("HUDShouldDraw", "Modules_DisableHud", function()
            return false
        end)

        -- Frame
        local frame = vgui.Create("Panel")
        frame:SetSize(0, 0)
        frame:InvalidateLayout(true)

        frame:MakePopup(true)

        function frame:PerformLayout(w, h)
            frame:SetSize(ScrW(), ScrH() * .15)
            frame:SetPos(0, ScrH() - ScrH() * .15)
        end

        function frame:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
        end

        -- Play Button
        
        local playbtn = frame:Add("DButton")
        playbtn:SetSize(0,0)
        playbtn:InvalidateLayout(true)

        playbtn:SetFont("Module_LoadMenu_Button")

        playbtn:SetTextColor(Color(255,255,255))

        playbtn:SetText("Play")

        function playbtn:PerformLayout(w, h)
            playbtn:SetSize(frame:GetWide() * .2, 100)
            playbtn:DockMargin(30, 30, 0, 30)
            playbtn:Dock(LEFT)
        end

        function playbtn.DoClick()
            frame:Remove()
            hook.Remove("CalcView", "Module_LoadMenu_CamPos")
            hook.Remove("HUDShouldDraw", "Modules_DisableHud")
        end

        function playbtn:Paint(w, h)
            if (self:IsHovered()) then
                draw.RoundedBox(0, 0, 0, w, h, Color(40,40,40,200))
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
            end
        end

        -- Credits button

        local creditbtn = frame:Add("DButton")
        creditbtn:SetSize(0,0)
        creditbtn:InvalidateLayout(true)

        creditbtn:SetFont("Module_LoadMenu_Button")

        creditbtn:SetTextColor(Color(255,255,255))

        creditbtn:SetText("Credits")

        function creditbtn:PerformLayout(w, h)
            creditbtn:SetSize(frame:GetWide() * .2, 100)
            creditbtn:DockMargin(0, 30, 30, 30)
            creditbtn:Dock(RIGHT)
        end

        function creditbtn.DoClick()   
            local creditframe = vgui.Create("Panel")
            creditframe:SetSize(0, 0)
            creditframe:InvalidateLayout(true)

            function creditframe:PerformLayout(w, h)
                creditframe:SetSize(1000, 500)
                creditframe:Center()
            end

            function creditframe:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
            end

            local header = creditframe:Add("Panel")
            header:Dock(TOP)

            function header:PerformLayout(w, h)
                header:Dock(TOP)
                header:SetSize(creditframe:GetWide(), 25)
            end
            
            function header:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(40,40,40,200))
            end

            local closebtn = header:Add("DButton")

            function closebtn:PerformLayout(w, h)
                closebtn:Dock(RIGHT)
                closebtn:SetSize(50, 25)
            end

            function closebtn.DoClick()
                creditframe:Remove()
            end

            closebtn:SetText("Close")
            closebtn:SetTextColor(Color(255,255,255))

            function closebtn:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
            end

            local label = creditframe:Add("DLabel")
            
            function label:PerformLayout(w, h)
                label:Dock(TOP)
                label:SetContentAlignment(5)
            end

            label:SetText("Programming / UI / Idea: LionDaDev")
        end

        function creditbtn:Paint(w, h)
            if (self:IsHovered()) then
                draw.RoundedBox(0, 0, 0, w, h, Color(40,40,40,200))
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,100))
            end
        end

    end

    net.Receive("Module_OpenLoadMenuNet", function()

        OpenLoadMenu()
    
    end)
end