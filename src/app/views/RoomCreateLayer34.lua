local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventType = require("common.EventType")
local Bit = require("common.Bit")

local RoomCreateLayer = class("RoomCreateLayer", cc.load("mvc").ViewBase)

function RoomCreateLayer:onEnter()
    EventMgr:registListener(EventType.SUB_CL_FRIENDROOM_CONFIG,self,self.SUB_CL_FRIENDROOM_CONFIG)
    EventMgr:registListener(EventType.SUB_CL_FRIENDROOM_CONFIG_END,self,self.SUB_CL_FRIENDROOM_CONFIG_END)
end

function RoomCreateLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_CL_FRIENDROOM_CONFIG,self,self.SUB_CL_FRIENDROOM_CONFIG)
    EventMgr:unregistListener(EventType.SUB_CL_FRIENDROOM_CONFIG_END,self,self.SUB_CL_FRIENDROOM_CONFIG_END)
end

function RoomCreateLayer:onCleanup()

end

function RoomCreateLayer:onCreate(parameter)
    self.wKindID  = parameter[1]
    self.showType = parameter[2]
    self.dwClubID = parameter[3]


    if CHANNEL_ID == 10 or CHANNEL_ID == 11 then
        self:initUI1011()
    else
        self:initUI()
    end

    if self.showType == 3 then
        self.tableFriendsRoomParams = {[1] = {wGameCount = 1}}
        self:SUB_CL_FRIENDROOM_CONFIG_END()
    else
        UserData.Game:sendMsgGetFriendsRoomParam(self.wKindID)
    end
end

function RoomCreateLayer:initUI()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = nil
    csb = cc.CSLoader:createNode("RoomCreateLayer34.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.recordCreateParameter = UserData.Game:readCreateParameter(self.wKindID)
    if self.recordCreateParameter == nil then
        self.recordCreateParameter = {}
    end
    
    local uiListView_create = ccui.Helper:seekWidgetByName(self.root,"ListView_create")
    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    Common:addTouchEventListener(uiButton_create,function() self:onEventCreate(0) end)
    local uiButton_guild = ccui.Helper:seekWidgetByName(self.root,"Button_guild")
    Common:addTouchEventListener(uiButton_guild,function() self:onEventCreate(1) end)
    local uiButton_help = ccui.Helper:seekWidgetByName(self.root,"Button_help")
    Common:addTouchEventListener(uiButton_help,function() self:onEventCreate(-1) end)
    local uiButton_settings = ccui.Helper:seekWidgetByName(self.root,"Button_settings")
    Common:addTouchEventListener(uiButton_settings,function() self:onEventCreate(-2) end)
    if self.showType ~= nil and self.showType == 1 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        
    elseif self.showType ~= nil and self.showType == 3 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        
    elseif self.showType ~= nil and self.showType == 2 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(1)
        uiListView_create:removeItem(1)
    else
        uiListView_create:removeItem(3)
        uiListView_create:removeItem(0)

        if StaticData.Hide[CHANNEL_ID].btn11 ~= 1 then 
            uiListView_create:removeItem(uiListView_create:getIndex(uiButton_help))
        end 
    end
    uiListView_create:refreshView()
    uiListView_create:setContentSize(cc.size(uiListView_create:getInnerContainerSize().width,uiListView_create:getInnerContainerSize().height))
    uiListView_create:setPositionX(uiListView_create:getParent():getContentSize().width/2)
    
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    uiListView_parameterList:getItem(0):setVisible(false)
    Common:addCheckTouchEventListener(items)
    --选择王数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bLaiZiCount"] ~= nil and self.recordCreateParameter["bLaiZiCount"] == 0 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bLaiZiCount"] ~= nil and self.recordCreateParameter["bLaiZiCount"] == 2 then
        items[3]:setBright(true)
    else
        items[2]:setBright(true)
    end
    --选择人数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bPlayerCount"] ~= nil and self.recordCreateParameter["bPlayerCount"] == 3 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bPlayerCount"] ~= nil and self.recordCreateParameter["bPlayerCount"] == 2 then
        items[3]:setBright(true)
    else
        items[2]:setBright(true)
    end
    --选择翻省
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        if index == 3 then
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
            for key, var in pairs(items) do
                var:setBright(false)
                var:setEnabled(false)
                var:setColor(cc.c3b(170,170,170))
            end
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
            for key, var in pairs(items) do
                var:setBright(false)
                var:setEnabled(false)
                var:setColor(cc.c3b(170,170,170))
            end
        else
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
            local isHaveDefault = false
            for key, var in pairs(items) do
                var:setEnabled(true)
                var:setColor(cc.c3b(255,255,255))
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
            end
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
            local isHaveDefault = false
            for key, var in pairs(items) do
                var:setEnabled(true)
                var:setColor(cc.c3b(255,255,255))
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
            end
        end
    end)
    if self.recordCreateParameter["FanXing"] ~= nil and self.recordCreateParameter["FanXing"]["bType"] == 2 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["FanXing"] ~= nil and self.recordCreateParameter["FanXing"]["bType"] == 0 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end
    --单双翻省
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["FanXing"] ~= nil and self.recordCreateParameter["FanXing"]["bType"] == 0 then
        for key, var in pairs(items) do
            var:setBright(false)
            var:setEnabled(false)
            var:setColor(cc.c3b(170,170,170))
        end
    elseif self.recordCreateParameter["bDouble"] ~= nil and self.recordCreateParameter["bDouble"] == 1 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end
    -- --翻省囤数
    -- local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    -- Common:addCheckTouchEventListener(items)
    -- if self.recordCreateParameter["FanXing"] ~= nil and self.recordCreateParameter["FanXing"]["bType"] == 0 then
    --     for key, var in pairs(items) do
    --         var:setBright(false)
    --         var:setEnabled(false)
    --         var:setColor(cc.c3b(170,170,170))
    --     end
    -- else
    --     items[1]:setBright(true)
    -- end
    --单局上限
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 300 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 600 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end
    if self.showType == 3 then
        items[1]:setBright(true)

        items[2]:setBright(false)
        items[2]:setEnabled(false)
        items[2]:setColor(cc.c3b(170,170,170))

        items[3]:setBright(false)
        items[3]:setEnabled(false)
        items[3]:setColor(cc.c3b(170,170,170))
    end
end


function RoomCreateLayer:initUI1011()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = nil
    csb = cc.CSLoader:createNode("RoomCreateLayer34_1011.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.recordCreateParameter = UserData.Game:readCreateParameter(self.wKindID)
    if self.recordCreateParameter == nil then
        self.recordCreateParameter = {}
    end
    
    local uiListView_create = ccui.Helper:seekWidgetByName(self.root,"ListView_create")
    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    Common:addTouchEventListener(uiButton_create,function() self:onEventCreate(0) end)
    local uiButton_guild = ccui.Helper:seekWidgetByName(self.root,"Button_guild")
    Common:addTouchEventListener(uiButton_guild,function() self:onEventCreate(1) end)
    local uiButton_help = ccui.Helper:seekWidgetByName(self.root,"Button_help")
    Common:addTouchEventListener(uiButton_help,function() self:onEventCreate(-1) end)
    local uiButton_settings = ccui.Helper:seekWidgetByName(self.root,"Button_settings")
    Common:addTouchEventListener(uiButton_settings,function() self:onEventCreate(-2) end)
    if self.showType ~= nil and self.showType == 1 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        
    elseif self.showType ~= nil and self.showType == 3 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        
    elseif self.showType ~= nil and self.showType == 2 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(1)
        uiListView_create:removeItem(1)
    else
        uiListView_create:removeItem(3)
        uiListView_create:removeItem(0)

        if StaticData.Hide[CHANNEL_ID].btn11 ~= 1 then 
            uiListView_create:removeItem(uiListView_create:getIndex(uiButton_help))
        end 
    end
    uiListView_create:refreshView()
    uiListView_create:setContentSize(cc.size(uiListView_create:getInnerContainerSize().width,uiListView_create:getInnerContainerSize().height))
    uiListView_create:setPositionX(uiListView_create:getParent():getContentSize().width/2)
    
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    uiListView_parameterList:getItem(0):setVisible(false)
    Common:addCheckTouchEventListener(items)
    --选择王数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bLaiZiCount"] ~= nil and self.recordCreateParameter["bLaiZiCount"] == 0 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bLaiZiCount"] ~= nil and self.recordCreateParameter["bLaiZiCount"] == 2 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["bLaiZiCount"] ~= nil and self.recordCreateParameter["bLaiZiCount"] == 3 then
        items[4]:setBright(true)
    else
        items[2]:setBright(true)
    end
    --选择人数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
        if index == 3 then                       
            local isHaveDefault = false
            for key, var in pairs(items) do
                var:setEnabled(true)
                var:setColor(cc.c3b(255,255,255))
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
           end
        else   
            for key, var in pairs(items) do
                var:setBright(false)
                var:setEnabled(false)
                var:setColor(cc.c3b(170,170,170))
            end     
        end       
    end )
    if self.recordCreateParameter["bPlayerCount"] ~= nil and self.recordCreateParameter["bPlayerCount"] == 3 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bPlayerCount"] ~= nil and self.recordCreateParameter["bPlayerCount"] == 2 then
        items[3]:setBright(true)
    else
        items[2]:setBright(true)
    end
    --选择翻省
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        if index == 3 then
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
            for key, var in pairs(items) do
                var:setBright(false)
                var:setEnabled(false)
                var:setColor(cc.c3b(170,170,170))
            end
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
            for key, var in pairs(items) do
                var:setBright(false)
                var:setEnabled(false)
                var:setColor(cc.c3b(170,170,170))
            end
        else
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
            local isHaveDefault = false
            for key, var in pairs(items) do
                var:setEnabled(true)
                var:setColor(cc.c3b(255,255,255))
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
            end
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
            local isHaveDefault = false
            for key, var in pairs(items) do
                var:setEnabled(true)
                var:setColor(cc.c3b(255,255,255))
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
            end
        end
    end)
    if self.recordCreateParameter["FanXing"] ~= nil and self.recordCreateParameter["FanXing"]["bType"] == 2 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["FanXing"] ~= nil and self.recordCreateParameter["FanXing"]["bType"] == 0 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end
    --单双翻省
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["FanXing"] ~= nil and self.recordCreateParameter["FanXing"]["bType"] == 0 then
        for key, var in pairs(items) do
            var:setBright(false)
            var:setEnabled(false)
            var:setColor(cc.c3b(170,170,170))
        end
    elseif self.recordCreateParameter["bDouble"] ~= nil and self.recordCreateParameter["bDouble"] == 1 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end
    -- --翻省囤数
    -- local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    -- Common:addCheckTouchEventListener(items)
    -- if self.recordCreateParameter["FanXing"] ~= nil and self.recordCreateParameter["FanXing"]["bType"] == 0 then
    --     for key, var in pairs(items) do
    --         var:setBright(false)
    --         var:setEnabled(false)
    --         var:setColor(cc.c3b(170,170,170))
    --     end
    -- else
    --     items[1]:setBright(true)
    -- end
    --单局上限
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 300 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 600 then
        items[3]:setBright(true)
    else
        items[1]:setBright(true)
    end
    if self.showType == 3 then
        items[1]:setBright(true)

        items[2]:setBright(false)
        items[2]:setEnabled(false)
        items[2]:setColor(cc.c3b(170,170,170))

        items[3]:setBright(false)
        items[3]:setEnabled(false)
        items[3]:setColor(cc.c3b(170,170,170))
    end

    --托管时间
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
        if index == 1 or index == 2 or index == 3 then         
            for key, var in pairs(items) do
                var:setBright(false)
            end
        else
            local isHaveDefault = false
            for key, var in pairs(items) do
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
            end
        end
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
        if index == 1 then         
            for key, var in pairs(items) do
                var:setBright(false)
                var:setBright(false)
                var:setEnabled(false)
                var:setColor(cc.c3b(170,170,170))
            end
        else
            local isHaveDefault = false
            for key, var in pairs(items) do
                var:setEnabled(true)
                var:setColor(cc.c3b(255,255,255)) 
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
            end
        end
    end)
    if self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 1 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 2 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 3 then
        for key, var in pairs(items) do
            var:setBright(false)
        end
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 5 then
        for key, var in pairs(items) do
            var:setBright(false)
        end
    else
        items[1]:setBright(true)
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index) 
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
        if index == 1 or index == 2 then         
            for key, var in pairs(items) do
                var:setBright(false)
            end
        else
            local isHaveDefault = false
            for key, var in pairs(items) do
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                items[1]:setBright(true)
            end
        end

        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
        if index == 1 or index == 2 then            
            local isHaveDefault = false
            for key, var in pairs(items) do
                var:setEnabled(true)
                var:setColor(cc.c3b(255,255,255)) 
                if var:isBright() then
                    isHaveDefault = true
                end
            end
            if isHaveDefault == false then
                var:setBright(true)
            end
        end
    end)
    if self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 1 then
        for key, var in pairs(items) do
            var:setBright(false)
        end
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 2 then
        for key, var in pairs(items) do
            var:setBright(false)
        end
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 3 then
        items[1]:setBright(true)
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 5 then
        items[2]:setBright(true)
    elseif self.recordCreateParameter["bHostedTime"] ~= nil and self.recordCreateParameter["bHostedTime"] == 0 then
        for key, var in pairs(items) do
            var:setBright(false)
        end
    end

    --选择托管局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items)
    if self.recordCreateParameter["bHostedTime"] == nil or self.recordCreateParameter["bHostedTime"] == 0 then
        for key, var in pairs(items) do
            var:setBright(false)
            var:setBright(false)
            var:setEnabled(false)
            var:setColor(cc.c3b(170,170,170))
        end
    elseif self.recordCreateParameter["bHostedSession"] ~= nil and self.recordCreateParameter["bHostedSession"] == 3 then
        items[3]:setBright(true)
    elseif self.recordCreateParameter["bHostedSession"] ~= nil and self.recordCreateParameter["bHostedSession"] >= 6 then
        items[2]:setBright(true)
    else
        items[1]:setBright(true)
    end

    --亡牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(9),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bPlayerCount"] == nil or self.recordCreateParameter["bPlayerCount"] ~= 2 then 
        items[1]:setBright(false)
        items[1]:setEnabled(false)
        items[1]:setColor(cc.c3b(170,170,170))
    elseif self.recordCreateParameter["bDeathCard"] == nil or Bit:_and(0x10,self.recordCreateParameter["bDeathCard"]) ~= 0 then
        items[1]:setBright(true)
    end

end



function RoomCreateLayer:SUB_CL_FRIENDROOM_CONFIG(event)
    local data = event._usedata
    if data.wKindID ~= self.wKindID then
        return
    end
    if self.tableFriendsRoomParams == nil then
        self.tableFriendsRoomParams = {}
    end
    self.tableFriendsRoomParams[data.dwIndexes] = data
end

function RoomCreateLayer:SUB_CL_FRIENDROOM_CONFIG_END(event)
    if self.tableFriendsRoomParams == nil then
        return
    end
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    local uiListView_parameter = uiListView_parameterList:getItem(0)
    uiListView_parameter:setVisible(true)
    local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
    local isFound = false
    for key, var in pairs(items) do
        local data = self.tableFriendsRoomParams[key]
    	if data then
            local uiText_desc = ccui.Helper:seekWidgetByName(var,"Text_desc")
            uiText_desc:setString(string.format("%d局",data.wGameCount))
            local uiText_addition = ccui.Helper:seekWidgetByName(var,"Text_addition")
            if data.dwExpendType == 1 then
                uiText_addition:setString(string.format("金币x%d",data.dwExpendCount))
            elseif data.dwExpendType == 2 then
                uiText_addition:setString(string.format("元宝x%d",data.dwExpendCount))
            elseif data.dwExpendType == 3 then
                uiText_addition:setString(string.format("(%sx%d)",StaticData.Items[data.dwSubType].name,data.dwExpendCount))   
            else
                uiText_addition:setString("(无消耗)")
            end
            if isFound == false and self.recordCreateParameter["wGameCount"] ~= nil and self.recordCreateParameter["wGameCount"] == data.wGameCount then
                var:setBright(true)
                isFound = true
            end
    	else
    	   var:setBright(false)
    	   var:setVisible(false)
    	end
    end
    if isFound == false and items[1]:isVisible() then
        items[1]:setBright(true)
    end
end

function RoomCreateLayer:onEventCreate(nTableType)
    NetMgr:getGameInstance():closeConnect()
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    self.tableParameter = {}

    if CHANNEL_ID == 10 or CHANNEL_ID == 11 then
        self:setParameter1011()
    else
        self:setParameter()
    end
   if self.showType ~= 2 and (nTableType == TableType_FriendRoom or nTableType == TableType_HelpRoom) then
        --普通创房和代开需要判断金币
        local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
        local uiListView_parameter = uiListView_parameterList:getItem(0)
        local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
        for key, var in pairs(items) do
            if var:isBright() then
                local data = self.tableFriendsRoomParams[key]
                if data.dwExpendType == 0 then--无消耗
                elseif data.dwExpendType == 1 then--金币
                    if UserData.User.dwGold  < data.dwExpendCount then
                        require("common.MsgBoxLayer"):create(0,nil,"您的金币不足!")
                        return
                    end  
                elseif data.dwExpendType == 2 then--元宝
                    if UserData.User.dwIngot  < data.dwExpendCount then
                        require("common.MsgBoxLayer"):create(0,nil,"您的元宝不足!")
                        return
                    end 
                elseif data.dwExpendType == 3 then--道具
                    local itemCount = UserData.Bag:getBagPropCount(data.dwSubType)
                    if itemCount < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的道具不足,请前往商城购买?",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("MallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(0,nil,"您的道具不足!")
                        end
                        return
                    end
                else
                    return
                end
                break
            end
        end
    end

    UserData.Game:saveCreateParameter(self.wKindID,self.tableParameter)

    --亲友圈自定义创房
    if self.showType == 2 then
        local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
        uiButton_create:removeAllChildren()
        uiButton_create:addChild(require("app.MyApp"):create(TableType_ClubRoom,1,self.wKindID,self.tableParameter.wGameCount,self.dwClubID,self.tableParameter):createView("InterfaceCreateRoomNode"))
        return
    end 
    --设置亲友圈   
    if nTableType == TableType_ClubRoom then
        EventMgr:dispatch(EventType.EVENT_TYPE_SETTINGS_CLUB_PARAMETER,{wKindID = self.wKindID,wGameCount = self.tableParameter.wGameCount,tableParameter = self.tableParameter})      
        return
    end

    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    uiButton_create:removeAllChildren()
    uiButton_create:addChild(require("app.MyApp"):create(nTableType,0,self.wKindID,self.tableParameter.wGameCount,UserData.Guild.dwPresidentID,self.tableParameter):createView("InterfaceCreateRoomNode"))

end

function RoomCreateLayer:setParameter()

    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")


     --选择局数
     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
     if items[1]:isBright() and self.tableFriendsRoomParams[1] then
         self.tableParameter.wGameCount = self.tableFriendsRoomParams[1].wGameCount
     elseif items[2]:isBright() and self.tableFriendsRoomParams[2] then
         self.tableParameter.wGameCount = self.tableFriendsRoomParams[2].wGameCount
     elseif items[3]:isBright() and self.tableFriendsRoomParams[3] then
         self.tableParameter.wGameCount = self.tableFriendsRoomParams[3].wGameCount
     else
         return
     end
     --选择王数
     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
     if items[1]:isBright() then
        self.tableParameter.bLaiZiCount = 0
     elseif items[2]:isBright() then
        self.tableParameter.bLaiZiCount = 1
     elseif items[3]:isBright() then
        self.tableParameter.bLaiZiCount = 2
     else
         return
     end
     --选择人数
     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
     if items[1]:isBright() then
         self.tableParameter.bPlayerCountType = 0
         self.tableParameter.bPlayerCount = 3
     elseif items[2]:isBright() then
         self.tableParameter.bPlayerCountType = 1
         self.tableParameter.bPlayerCount = 4
     elseif items[3]:isBright() then
         self.tableParameter.bPlayerCountType = 0
         self.tableParameter.bPlayerCount = 2
     else
         return
     end
     --选择翻省
     self.tableParameter.FanXing = {}
     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
     if items[1]:isBright() then
         self.tableParameter.FanXing.bType = 3
         self.tableParameter.FanXing.bCount = 1
     elseif items[2]:isBright() then
         self.tableParameter.FanXing.bType = 2
         self.tableParameter.FanXing.bCount = 1
     elseif items[3]:isBright() then
         self.tableParameter.FanXing.bType = 0
         self.tableParameter.FanXing.bCount = 0
     else
         return
     end
     --单双翻省
     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
     if items[1]:isBright() then
         self.tableParameter.bDouble = 0
     elseif items[2]:isBright() then
         self.tableParameter.bDouble = 1
     else    
         self.tableParameter.bDouble = 0
     end
     --翻省囤数
     if self.tableParameter.FanXing.bType ~= 0 then     
         self.tableParameter.FanXing.bAddTun = 3
     else
         self.tableParameter.FanXing.bAddTun = 0
     end
     --单局上限
     local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
     if items[1]:isBright() then
         self.tableParameter.bMaxLost = 0
     elseif items[2]:isBright() then
         self.tableParameter.bMaxLost = 300
     elseif items[3]:isBright() then
         self.tableParameter.bMaxLost = 600
     else
         return
     end
     self.tableParameter.bYiWuShi = 0
     self.tableParameter.bLiangPai = 0
     self.tableParameter.bCanHuXi = 6
     self.tableParameter.bHuType = 0
     self.tableParameter.bFangPao = 0
     self.tableParameter.bSettlement = 0
     self.tableParameter.bStartTun = 0
     self.tableParameter.bSocreType = 1
     self.tableParameter.dwMingTang = 0xFFF
end 

function RoomCreateLayer:setParameter1011()

    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")

    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    if items[1]:isBright() and self.tableFriendsRoomParams[1] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[1].wGameCount
    elseif items[2]:isBright() and self.tableFriendsRoomParams[2] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[2].wGameCount
    elseif items[3]:isBright() and self.tableFriendsRoomParams[3] then
        self.tableParameter.wGameCount = self.tableFriendsRoomParams[3].wGameCount
    else
        return
    end
    --选择王数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bLaiZiCount = 0
    elseif items[2]:isBright() then
        self.tableParameter.bLaiZiCount = 1
    elseif items[3]:isBright() then
        self.tableParameter.bLaiZiCount = 2
    elseif items[4]:isBright() then
        self.tableParameter.bLaiZiCount = 3
    else
        return
    end
    --选择人数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(2),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bPlayerCountType = 0
        self.tableParameter.bPlayerCount = 3
    elseif items[2]:isBright() then
        self.tableParameter.bPlayerCountType = 1
        self.tableParameter.bPlayerCount = 4
    elseif items[3]:isBright() then
        self.tableParameter.bPlayerCountType = 0
        self.tableParameter.bPlayerCount = 2
    else
        return
    end
    --选择翻省
    self.tableParameter.FanXing = {}
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(3),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.FanXing.bType = 3
        self.tableParameter.FanXing.bCount = 1
    elseif items[2]:isBright() then
        self.tableParameter.FanXing.bType = 2
        self.tableParameter.FanXing.bCount = 1
    elseif items[3]:isBright() then
        self.tableParameter.FanXing.bType = 0
        self.tableParameter.FanXing.bCount = 0
    else
        return
    end
    --单双翻省
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(4),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bDouble = 0
    elseif items[2]:isBright() then
        self.tableParameter.bDouble = 1
    else    
        self.tableParameter.bDouble = 0
    end
    --翻省囤数
    if self.tableParameter.FanXing.bType ~= 0 then     
        self.tableParameter.FanXing.bAddTun = 3
    else
        self.tableParameter.FanXing.bAddTun = 0
    end
    --托管时间
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(5),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bMaxLost = 0
    elseif items[2]:isBright() then
        self.tableParameter.bMaxLost = 300
    elseif items[3]:isBright() then
        self.tableParameter.bMaxLost = 600
    else
        return
    end

    --托管时间
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(6),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bHostedTime = 0
    elseif items[2]:isBright() then
        self.tableParameter.bHostedTime = 1
    elseif items[3]:isBright() then
        self.tableParameter.bHostedTime = 2
    end

    --托管时间
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(7),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bHostedTime = 3
    elseif items[2]:isBright() then
        self.tableParameter.bHostedTime = 5
    end

    self.tableParameter.bHostedSession = 0
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(8),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bHostedSession = 1
    elseif items[2]:isBright() then
        self.tableParameter.bHostedSession =  self.tableParameter.wGameCount
    elseif items[3]:isBright() then
        self.tableParameter.bHostedSession = 3
    end  

    --单局上限
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(9),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        self.tableParameter.bDeathCard = 1
    else
        self.tableParameter.bDeathCard = 0
    end

    self.tableParameter.bYiWuShi = 0
    self.tableParameter.bLiangPai = 0
    self.tableParameter.bCanHuXi = 6
    self.tableParameter.bHuType = 0
    self.tableParameter.bFangPao = 0
    self.tableParameter.bSettlement = 0
    self.tableParameter.bStartTun = 0
    self.tableParameter.bSocreType = 1
    self.tableParameter.dwMingTang = 0xFFF
end 
return RoomCreateLayer
