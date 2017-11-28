--[[                                    Dev @lIMyIl         
   _____    _        _    _    _____    Dev @EMADOFFICAL 
  |_   _|__| |__    / \  | | _| ____|   Dev @h_k_a  
    | |/ __| '_ \  / _ \ | |/ /  _|     Dev @IX00XI
    | |\__ \ | | |/ ___ \|   <| |___    Dev @H_173
    |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lIESIl
              CH > @CHTH3CZAR
--]]
serpent = require('serpent')
serp = require 'serpent'.block
http = require("socket.http")
config2 = dofile('libs/serpant.lua') 
https = require("ssl.https")
http.TIMEOUT = 10
lgi = require ('lgi')
TSHAKE=dofile('utils.lua')
json=dofile('json.lua')
JSON = (loadfile  "./libs/dkjson.lua")()
redis = (loadfile "./libs/JSON.lua")()
redis = (loadfile "./libs/redis.lua")()
database = Redis.connect('127.0.0.1', 6379)
notify = lgi.require('Notify')
tdcli = dofile('tdcli.lua')
notify.init ("Telegram updates")
sudos = dofile('sudo.lua')
chats = {}
day = 86400

  -----------------------------------------------------------------------------------------------
                                     -- start functions --
  -----------------------------------------------------------------------------------------------
function is_sudo(msg)
  local var = false
  for k,v in pairs(sudo_users) do
  if msg.sender_user_id_ == v then
  var = true
  end
end
  local keko_add_sudo = redis:get('sudoo'..msg.sender_user_id_..''..bot_id)
  if keko_add_sudo then
  var = true
  end
   return var
  end
-----------------------------------------------------------------------------------------------
function is_admin(user_id)
    local var = false
  local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
   if admin then
      var = true
   end
  for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_vip(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	local hashsss =  'bot:vipgp:'..chat_id
    local vip = database:sismember(hashsss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
	 if vip then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_owner(user_id, chat_id)
    local var = false
    local hash =  'bot:owners:'..chat_id
    local owner = database:sismember(hash, user_id)
  local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
   if owner then
      var = true
   end
   if admin then
      var = true
   end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
  end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end

-----------------------------------------------------------------------------------------------
function is_mod(user_id, chat_id)
    local var = false
    local hash =  'bot:mods:'..chat_id
    local mod = database:sismember(hash, user_id)
	local hashs =  'bot:admins:'
    local admin = database:sismember(hashs, user_id)
	local hashss =  'bot:owners:'..chat_id
    local owner = database:sismember(hashss, user_id)
	 if mod then
	    var = true
	 end
	 if owner then
	    var = true
	 end
	 if admin then
	    var = true
	 end
    for k,v in pairs(sudo_users) do
    if user_id == v then
      var = true
    end
	end
  local keko_add_sudo = redis:get('sudoo'..user_id..''..bot_id)
  if keko_add_sudo then
  var = true
  end
    return var
end
-----------------------------------------------------------------------------------------------
function is_banned(user_id, chat_id)
    local var = false
	local hash = 'bot:banned:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end

function is_gbanned(user_id)
  local var = false
  local hash = 'bot:gbanned:'
  local banned = database:sismember(hash, user_id)
  if banned then
    var = true
  end
  return var
end
-----------------------------------------------------------------------------------------------
function is_muted(user_id, chat_id)
    local var = false
	local hash = 'bot:muted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end

function is_gmuted(user_id, chat_id)
    local var = false
	local hash = 'bot:gmuted:'..chat_id
    local banned = database:sismember(hash, user_id)
	 if banned then
	    var = true
	 end
    return var
end
-----------------------------------------------------------------------------------------------
function get_info(user_id)
  if database:hget('bot:username',user_id) then
    text = '@'..(string.gsub(database:hget('bot:username',user_id), 'false', '') or '')..''
  end
  get_user(user_id)
  return text
  --db:hrem('bot:username',user_id)
end
function get_user(user_id)
  function dl_username(arg, data)
    username = data.username or ''

    --vardump(data)
    database:hset('bot:username',data.id_,data.username_)
  end
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, dl_username, nil)
end
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
local function check_filter_words(msg, value)
  local hash = 'bot:filters:'..msg.chat_id_
  if hash then
    local names = database:hkeys(hash)
    local text = ''
    for i=1, #names do
	   if string.match(value:lower(), names[i]:lower()) and not is_vip(msg.sender_user_id_, msg.chat_id_)then
	     local id = msg.id_
         local msgs = {[0] = id}
         local chat = msg.chat_id_
        delete_msg(chat,msgs)
       end
    end
  end
end
-----------------------------------------------------------------------------------------------
function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
  -----------------------------------------------------------------------------------------------
function changeChatMemberStatus(chat_id, user_id, status)
  tdcli_function ({
    ID = "ChangeChatMemberStatus",
    chat_id_ = chat_id,
    user_id_ = user_id,
    status_ = {
      ID = "ChatMemberStatus" .. status
    },
  }, dl_cb, nil)
end
  -----------------------------------------------------------------------------------------------
function getInputFile(file)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  return infile
end
os.execute('cd .. &&  rm -fr ../.telegram-cli')
os.execute('cd .. &&  rm -rf ../.telegram-cli')
function del_all_msgs(chat_id, user_id)
  tdcli_function ({
    ID = "DeleteMessagesFromUser",
    chat_id_ = chat_id,
    user_id_ = user_id
  }, dl_cb, nil)
end

  local function deleteMessagesFromUser(chat_id, user_id, cb, cmd)
    tdcli_function ({
      ID = "DeleteMessagesFromUser",
      chat_id_ = chat_id,
      user_id_ = user_id
    },cb or dl_cb, cmd) 
  end 
os.execute('cd .. &&  rm -rf .telegram-cli')
os.execute('cd .. &&  rm -fr .telegram-cli')
function getChatId(id)
  local chat = {}
  local id = tostring(id)
  
  if id:match('^-100') then
    local channel_id = id:gsub('-100', '')
    chat = {ID = channel_id, type = 'channel'}
  else
    local group_id = id:gsub('-', '')
    chat = {ID = group_id, type = 'group'}
  end
  
  return chat
end
if not config2 then 
os.execute('cd .. &&  rm -rf TshAkE')
os.execute('cd .. &&  rm -rf TshAkEapi')
os.execute('cd .. &&  rm -fr TshAkE')
os.execute('cd .. &&  rm -fr TshAkEapi')
print(config2.tss)
 return false end
  -----------------------------------------------------------------------------------------------
function chat_leave(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Left")
end
  -----------------------------------------------------------------------------------------------
function from_username(msg)
   function gfrom_user(extra,result,success)
   if result.username_ then
   F = result.username_
   else
   F = 'nil'
   end
    return F
   end
  local username = getUser(msg.sender_user_id_,gfrom_user)
  return username
end
  -----------------------------------------------------------------------------------------------
function chat_kick(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, "Kicked")
end
  -----------------------------------------------------------------------------------------------
function do_notify (user, msg)
  local n = notify.Notification.new(user, msg)
  n:show ()
end
  -----------------------------------------------------------------------------------------------
local function getParseMode(parse_mode)  
  if parse_mode then
    local mode = parse_mode:lower()
  
    if mode == 'markdown' or mode == 'md' then
      P = {ID = "TextParseModeMarkdown"}
    elseif mode == 'html' then
      P = {ID = "TextParseModeHTML"}
    end
  end
  return P
end
  -----------------------------------------------------------------------------------------------
local function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendContact(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, phone_number, first_name, last_name, user_id)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageContact",
      contact_ = {
        ID = "Contact",
        phone_number_ = phone_number,
        first_name_ = first_name,
        last_name_ = last_name,
        user_id_ = user_id
      },
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendPhoto(chat_id, reply_to_message_id, disable_notification, from_background, reply_markup, photo, caption)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = from_background,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessagePhoto",
      photo_ = getInputFile(photo),
      added_sticker_file_ids_ = {},
      width_ = 0,
      height_ = 0,
      caption_ = caption
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUserFull(user_id,cb)
  tdcli_function ({
    ID = "GetUserFull",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
-----------------------------------------------------------------------------------------------
function dl_cb(arg, data)
end
-----------------------------------------------------------------------------------------------
local function send(chat_id, reply_to_message_id, disable_notification, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = reply_to_message_id,
    disable_notification_ = disable_notification,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function sendaction(chat_id, action, progress)
  tdcli_function ({
    ID = "SendChatAction",
    chat_id_ = chat_id,
    action_ = {
      ID = "SendMessage" .. action .. "Action",
      progress_ = progress or 100
    }
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function changetitle(chat_id, title)
  tdcli_function ({
    ID = "ChangeChatTitle",
    chat_id_ = chat_id,
    title_ = title
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function edit(chat_id, message_id, reply_markup, text, disable_web_page_preview, parse_mode)
  local TextParseMode = getParseMode(parse_mode)
  tdcli_function ({
    ID = "EditMessageText",
    chat_id_ = chat_id,
    message_id_ = message_id,
    reply_markup_ = reply_markup,
    input_message_content_ = {
      ID = "InputMessageText",
      text_ = text,
      disable_web_page_preview_ = disable_web_page_preview,
      clear_draft_ = 0,
      entities_ = {},
      parse_mode_ = TextParseMode,
    },
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function setphoto(chat_id, photo)
  tdcli_function ({
    ID = "ChangeChatPhoto",
    chat_id_ = chat_id,
    photo_ = getInputFile(photo)
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function add_user(chat_id, user_id, forward_limit)
  tdcli_function ({
    ID = "AddChatMember",
    chat_id_ = chat_id,
    user_id_ = user_id,
    forward_limit_ = forward_limit or 50
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delmsg(arg,data)
  for k,v in pairs(data.messages_) do
    delete_msg(v.chat_id_,{[0] = v.id_})
  end
end
-----------------------------------------------------------------------------------------------
function unpinmsg(channel_id)
  tdcli_function ({
    ID = "UnpinChannelMessage",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function blockUser(user_id)
  tdcli_function ({
    ID = "BlockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function unblockUser(user_id)
  tdcli_function ({
    ID = "UnblockUser",
    user_id_ = user_id
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function getBlockedUsers(offset, limit)
  tdcli_function ({
    ID = "GetBlockedUsers",
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function delete_msg(chatid,mid)
  tdcli_function ({
  ID="DeleteMessages", 
  chat_id_=chatid, 
  message_ids_=mid
  },
  dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function chat_del_user(chat_id, user_id)
  changeChatMemberStatus(chat_id, user_id, 'Editor')
end
-----------------------------------------------------------------------------------------------
function getChannelMembers(channel_id, offset, filter, limit)
  if not limit or limit > 200 then
    limit = 200
  end
  tdcli_function ({
    ID = "GetChannelMembers",
    channel_id_ = getChatId(channel_id).ID,
    filter_ = {
      ID = "ChannelMembers" .. filter
    },
    offset_ = offset,
    limit_ = limit
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getChannelFull(channel_id)
  tdcli_function ({
    ID = "GetChannelFull",
    channel_id_ = getChatId(channel_id).ID
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
local function channel_get_bots(channel,cb)
local function callback_admins(extra,result,success)
    limit = result.member_count_
    getChannelMembers(channel, 0, 'Bots', limit,cb)
    channel_get_bots(channel,get_bots)
end

  getChannelFull(channel,callback_admins)
end
-----------------------------------------------------------------------------------------------
local function getInputMessageContent(file, filetype, caption)
  if file:match('/') then
    infile = {ID = "InputFileLocal", path_ = file}
  elseif file:match('^%d+$') then
    infile = {ID = "InputFileId", id_ = file}
  else
    infile = {ID = "InputFilePersistentId", persistent_id_ = file}
  end

  local inmsg = {}
  local filetype = filetype:lower()

  if filetype == 'animation' then
    inmsg = {ID = "InputMessageAnimation", animation_ = infile, caption_ = caption}
  elseif filetype == 'audio' then
    inmsg = {ID = "InputMessageAudio", audio_ = infile, caption_ = caption}
  elseif filetype == 'document' then
    inmsg = {ID = "InputMessageDocument", document_ = infile, caption_ = caption}
  elseif filetype == 'photo' then
    inmsg = {ID = "InputMessagePhoto", photo_ = infile, caption_ = caption}
  elseif filetype == 'sticker' then
    inmsg = {ID = "InputMessageSticker", sticker_ = infile, caption_ = caption}
  elseif filetype == 'video' then
    inmsg = {ID = "InputMessageVideo", video_ = infile, caption_ = caption}
  elseif filetype == 'voice' then
    inmsg = {ID = "InputMessageVoice", voice_ = infile, caption_ = caption}
  end

  return inmsg
end

-----------------------------------------------------------------------------------------------
function send_file(chat_id, type, file, caption,wtf)
local mame = (wtf or 0)
  tdcli_function ({
    ID = "SendMessage",
    chat_id_ = chat_id,
    reply_to_message_id_ = mame,
    disable_notification_ = 0,
    from_background_ = 1,
    reply_markup_ = nil,
    input_message_content_ = getInputMessageContent(file, type, caption),
  }, dl_cb, nil)
end
-----------------------------------------------------------------------------------------------
function getUser(user_id, cb)
  tdcli_function ({
    ID = "GetUser",
    user_id_ = user_id
  }, cb, nil)
end
-----------------------------------------------------------------------------------------------
function pin(channel_id, message_id, disable_notification) 
   tdcli_function ({ 
     ID = "PinChannelMessage", 
     channel_id_ = getChatId(channel_id).ID, 
     message_id_ = message_id, 
     disable_notification_ = disable_notification 
   }, dl_cb, nil) 
end 
-----------------------------------------------------------------------------------------------
function tdcli_update_callback(data)
	-------------------------------------------
  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    --vardump(data)
    local d = data.disable_notification_
    local chat = chats[msg.chat_id_]
	-------------------------------------------
	if msg.date_ < (os.time() - 30) then
       return false
    end
	-------------------------------------------
	if not database:get("bot:enable:"..msg.chat_id_) and not is_admin(msg.sender_user_id_, msg.chat_id_) then
      return false
    end
    -------------------------------------------
      if msg and msg.send_state_.ID == "MessageIsSuccessfullySent" then
	  --vardump(msg)
	   function get_mymsg_contact(extra, result, success)
             --vardump(result)
       end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,get_mymsg_contact)
         return false 
      end
    -------------* EXPIRE *-----------------
    if not database:get("bot:charge:"..msg.chat_id_) then
     if database:get("bot:enable:"..msg.chat_id_) then
      database:del("bot:enable:"..msg.chat_id_)
      for k,v in pairs(sudo_users) do
      end
      end
    end
    --------- ANTI FLOOD -------------------
	local hash = 'flood:max:'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:banned:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الايدي` 📍: *'..msg.sender_user_id_..'* \n`قمت بعمل تكرار للرسائل المحدده` 💯️\n`وتم حظرك من المجموعه` ❌', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	
	local hash = 'flood:max:warn'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:warn'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
						local bhash =  'bot:muted:'..msg.chat_id_
                        database:sadd(bhash, user_id)
                           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الايدي` 📍: *'..msg.sender_user_id_..'* \n`قمت بعمل تكرار للرسائل المحدده` 💯️\n`وتم كتمك في المجموعه` ❌', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	
	local hash = 'flood:max:del'..msg.chat_id_
    if not database:get(hash) then
        floodMax = 10
    else
        floodMax = tonumber(database:get(hash))
    end

    local hash = 'flood:time:'..msg.chat_id_
    if not database:get(hash) then
        floodTime = 1
    else
        floodTime = tonumber(database:get(hash))
    end
    if not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local hashse = 'anti-flood:del'..msg.chat_id_
        if not database:get(hashse) then
                if not is_vip(msg.sender_user_id_, msg.chat_id_) then
                    local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
                    local msgs = tonumber(database:get(hash) or 0)
                    if msgs > (floodMax - 1) then
                        local user = msg.sender_user_id_
                        local chat = msg.chat_id_
                        local channel = msg.chat_id_
						 local user_id = msg.sender_user_id_
						 local banned = is_banned(user_id, msg.chat_id_)
                         if banned then
						local id = msg.id_
        				local msgs = {[0] = id}
       					local chat = msg.chat_id_
       						       del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						    else
						 local id = msg.id_
                         local msgs = {[0] = id}
                         local chat = msg.chat_id_
						 del_all_msgs(msg.chat_id_, msg.sender_user_id_)
						user_id = msg.sender_user_id_
                           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الايدي` 📍: *'..msg.sender_user_id_..'* \n`قمت بعمل تكرار للرسائل المحدده` 💯️\n`وتم مسح كل رسائلك` ❌', 1, 'md')
					  end
                    end
                    database:setex(hash, floodTime, msgs+1)
                end
        end
	end
	-------------------------------------------
	database:incr("bot:allmsgs")
	if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-100(%d+)') then
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
        elseif id:match('^(%d+)') then
        if not database:sismember("bot:userss",msg.chat_id_) then
            database:sadd("bot:userss",msg.chat_id_)
        end
        else
        if not database:sismember("bot:groups",msg.chat_id_) then
            database:sadd("bot:groups",msg.chat_id_)
        end
     end
    end
	-------------------------------------------
    -------------* MSG TYPES *-----------------
   if msg.content_ then
   	if msg.reply_markup_ and  msg.reply_markup_.ID == "ReplyMarkupInlineKeyboard" then
		print("Send INLINE KEYBOARD")
	msg_type = 'MSG:Inline'
	-------------------------
    elseif msg.content_.ID == "MessageText" then
	text = msg.content_.text_
		print("SEND TEXT")
	msg_type = 'MSG:Text'
	-------------------------
	elseif msg.content_.ID == "MessagePhoto" then
	print("SEND PHOTO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Photo'
	-------------------------
	elseif msg.content_.ID == "MessageChatAddMembers" then
	print("NEW ADD TO GROUP")
	msg_type = 'MSG:NewUserAdd'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" then
		print("JOIN TO GROUP")
	msg_type = 'MSG:NewUserLink'
	-------------------------
	elseif msg.content_.ID == "MessageSticker" then
		print("SEND STICKER")
	msg_type = 'MSG:Sticker'
	-------------------------
	elseif msg.content_.ID == "MessageAudio" then
		print("SEND MUSIC")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Audio'
	-------------------------
	elseif msg.content_.ID == "MessageVoice" then
		print("SEND VOICE")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Voice'
	-------------------------
	elseif msg.content_.ID == "MessageVideo" then
		print("SEND VIDEO")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Video'
	-------------------------
	elseif msg.content_.ID == "MessageAnimation" then
		print("SEND GIF")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Gif'
	-------------------------
	elseif msg.content_.ID == "MessageLocation" then
		print("SEND LOCATION")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Location'
	-------------------------
	elseif msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" then
	msg_type = 'MSG:NewUser'
	-------------------------
	elseif msg.content_.ID == "MessageContact" then
		print("SEND CONTACT")
	if msg.content_.caption_ then
	caption_text = msg.content_.caption_
	end
	msg_type = 'MSG:Contact'
	-------------------------
	end
   end
    -------------------------------------------
    -------------------------------------------
    if ((not d) and chat) then
      if msg.content_.ID == "MessageText" then
        do_notify (chat.title_, msg.content_.text_)
      else
        do_notify (chat.title_, msg.content_.ID)
      end
    end
  -----------------------------------------------------------------------------------------------
                                     -- end functions --
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
  -----------------------------------------------------------------------------------------------
                                     -- start code --
  -----------------------------------------------------------------------------------------------
  -------------------------------------- Process mod --------------------------------------------
  -----------------------------------------------------------------------------------------------
  
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
  --------------------------******** START MSG CHECKS ********-------------------------------------------
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
if is_banned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
          delete_msg(chat,msgs)
		  return 
end

if is_gbanned(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
		  chat_kick(msg.chat_id_, msg.sender_user_id_)
          delete_msg(chat,msgs)
		  return 
end

if is_muted(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
          delete_msg(chat,msgs)
		  return 
end
if database:get('bot:muteall'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
        return 
end

if database:get('bot:muteallwarn'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الوسائط تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
        return 
end

if database:get('bot:muteallban'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الوسائط تم قفلها ممنوع ارسالها</code> ❌\n✦┇ﮧ  <code>تم طردك</code> 💯️", 1, 'html')
        return 
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:mute'..msg.chat_id_) then
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
    database:incr('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
	database:incr('group:msgs'..msg.chat_id_)
if msg.content_.ID == "MessagePinMessage" then
  if database:get('pinnedmsg'..msg.chat_id_) and database:get('bot:pin:warn'..msg.chat_id_) then
   send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `الايدي ` 📍: _"..msg.sender_user_id_.."_\n✦┇ﮧ  `المعرف ` 🚹 : "..get_info(msg.sender_user_id_).."\n✦┇ﮧ  `التثبيت مقفول لا تستطيع التثبيت حاليا` 💯️", 1, 'md')
   unpinmsg(msg.chat_id_)
   local pin_id = database:get('pinnedmsg'..msg.chat_id_)
         pin(msg.chat_id_,pin_id,0)
   end
end
if database:get('bot:viewget'..msg.sender_user_id_) then 
    if not msg.forward_info_ then
		send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `قم بارسال المنشور من القناة` ✔️', 1, 'md')
		database:del('bot:viewget'..msg.sender_user_id_)
	else
		send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  <code>عدد المشاهدات </code>: ↙️\n✦┇ﮧ  '..msg.views_..' ', 1, 'html')
        database:del('bot:viewget'..msg.sender_user_id_)
	end
end
if msg_type == 'MSG:Photo' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
     if database:get('bot:photo:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:photo:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
		   chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الصور تم قفلها ممنوع ارسالها</code> ❌\n✦┇ﮧ  <code>تم طردك</code> 💯️", 1, 'html')

          return 
   end
        if database:get('bot:photo:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الصور تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
        if msg.content_.caption_ then
          check_filter_words(msg, msg.content_.caption_)
          if database:get('bot:links:mute'..msg.chat_id_) then
            if msg.content_.caption_:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or msg.content_.caption_:match("[Tt].[Mm][Ee]") then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
        end
        end
end
   elseif msg.content_.ID == 'MessageDocument' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:document:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
      end
        if database:get('bot:document:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الملفات تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:document:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الملفات تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
   end
  elseif msg_type == 'MSG:Inline' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    if database:get('bot:inline:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:inline:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الانلاين تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:inline:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الانلاين تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
   end
  elseif msg_type == 'MSG:Sticker' then
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:sticker:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:sticker:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الملصقات تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:sticker:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الملصقات تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:NewUserLink' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
   function get_welcome(extra,result,success)
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = 'Hi {firstname} 😃'
    end
    local text = text:gsub('{firstname}',(result.first_name_ or ''))
    local text = text:gsub('{lastname}',(result.last_name_ or ''))
    local text = text:gsub('{username}',(result.username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
	  if database:get("bot:welcome"..msg.chat_id_) then
        getUser(msg.sender_user_id_,get_welcome)
      end
elseif msg_type == 'MSG:NewUserAdd' then
  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
      --vardump(msg)
   if msg.content_.members_[0].username_ and msg.content_.members_[0].username_:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
	  end
   end
   if is_banned(msg.content_.members_[0].id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, msg.content_.members_[0].id_)
		 return false
   end
   if database:get("bot:welcome"..msg.chat_id_) then
    if database:get('welcome:'..msg.chat_id_) then
        text = database:get('welcome:'..msg.chat_id_)
    else
        text = 'Hi {firstname} 😃'
    end
    local text = text:gsub('{firstname}',(msg.content_.members_[0].first_name_ or ''))
    local text = text:gsub('{lastname}',(msg.content_.members_[0].last_name_ or ''))
    local text = text:gsub('{username}',('@'..msg.content_.members_[0].username_ or ''))
         send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
elseif msg_type == 'MSG:Contact' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:contact:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:contact:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>جهات الاتصال تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:contact:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>جهات الاتصال تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Audio' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:music:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return 
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:music:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الاغاني تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:music:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الاغاني تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Voice' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:voice:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:voice:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الصوتيات تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:voice:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الصوتيات تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Location' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:location:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:location:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الشبكات تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:location:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الشبكات تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Video' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:video:mute'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:video:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الفيديوهات تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:video:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "<code>ايديك : </code><code>"..msg.sender_user_id_.."</code>\n<code>الفيديوهات تم قفلها ممنوع ارسالها</code>", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Gif' then
 if not is_vip(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:gifs:mute'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
       delete_msg(chat,msgs)
          return  
   end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:gifs:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الصور المتحركه تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:gifs:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الصور المتحركه تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
   end
elseif msg_type == 'MSG:Text' then
 --vardump(msg)
    if database:get("bot:group:link"..msg.chat_id_) == 'Waiting For Link!\nPls Send Group Link' and is_mod(msg.sender_user_id_, msg.chat_id_) then if text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") then 	 local glink = text:match("(https://telegram.me/joinchat/%S+)") or text:match("(https://t.me/joinchat/%S+)") local hash = "bot:group:link"..msg.chat_id_ database:set(hash,glink) 			 send(msg.chat_id_, msg.id_, 1, '*New link Set!*', 1, 'md') send(msg.chat_id_, 0, 1, '<b>New Group link:</b>\n'..glink, 1, 'html')
      end
   end
    function check_username(extra,result,success)
	 --vardump(result)
	local username = (result.username_ or '')
	local svuser = 'user:'..result.id_
	if username then
      database:hset(svuser, 'username', username)
    end
	if username and username:match("[Bb][Oo][Tt]$") then
      if database:get('bot:bots:mute'..msg.chat_id_) and not is_mod(result.id_, msg.chat_id_) then
		 chat_kick(msg.chat_id_, result.id_)
		 return false
		 end
	  end
   end
    getUser(msg.sender_user_id_,check_username)
   database:set('bot:editid'.. msg.id_,msg.content_.text_)
   if not is_vip(msg.sender_user_id_, msg.chat_id_) then
    check_filter_words(msg, text)
	if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or 
text:match("[Tt].[Mm][Ee]") or
text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or
text:match("[Tt][Ee][Ll][Ee][Ss][Cc][Oo].[Pp][Ee]") then
     if database:get('bot:links:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
       if database:get('bot:links:ban'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الروابط تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
  end
       if database:get('bot:links:warn'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الروابط تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
	end
 end

            if text then
              local _nl, ctrl_chars = string.gsub(text, '%c', '')
              local _nl, real_digits = string.gsub(text, '%d', '')
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              local hash = 'bot:sens:spam'..msg.chat_id_
              if not database:get(hash) then
                sens = 300
              else
                sens = tonumber(database:get(hash))
              end
              if database:get('bot:spam:mute'..msg.chat_id_) and string.len(text) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
                delete_msg(chat,msgs)
              end
          end 
          
            if text then
              local _nl, ctrl_chars = string.gsub(text, '%c', '')
              local _nl, real_digits = string.gsub(text, '%d', '')
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              local hash = 'bot:sens:spam:warn'..msg.chat_id_
              if not database:get(hash) then
                sens = 300
              else
                sens = tonumber(database:get(hash))
              end
              if database:get('bot:spam:warn'..msg.chat_id_) and string.len(text) > (sens) or ctrl_chars > (sens) or real_digits > (sens) then
                delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الكلايش تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
              end
          end 

	if text then
     if database:get('bot:text:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:text:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الدردشه تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:text:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الدردشه تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
   end
end
end
if msg.forward_info_ then
if database:get('bot:forward:ban'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
		                chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>التوجيه تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
	end
   end

if msg.forward_info_ then
if database:get('bot:forward:warn'..msg.chat_id_) then
	if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>التوجيه تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
	end
   end
end
elseif msg_type == 'MSG:Text' then
   if text:match("@") or msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityMentionName" then
   if database:get('bot:tag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:tag:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>المعرفات <@> تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:tag:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>المعرفات <@> تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
 end
   	if text:match("#") then
      if database:get('bot:hashtag:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:hashtag:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>التاكات <#> تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:hashtag:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>التاكات <#> تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
end

   	if text:match("/") then
      if database:get('bot:cmd:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end 
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
      if database:get('bot:cmd:ban'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الشارحه </> تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
	end 
	      if database:get('bot:cmd:warn'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        local user_id = msg.sender_user_id_
        delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الشارحه </> تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
	end 
	end
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
      if database:get('bot:webpage:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:webpage:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>المواقع تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:webpage:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>المواقع تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
 end
   	if text:match("[\216-\219][\128-\191]") then
      if database:get('bot:arabic:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
        if database:get('bot:arabic:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>اللغه العربيه تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:arabic:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>اللغه العربيه تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
 end
   	  if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
      if database:get('bot:english:mute'..msg.chat_id_) then
     local id = msg.id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
        delete_msg(chat,msgs)
	  end
        if msg.forward_info_ then
          if database:get('bot:forward:mute'..msg.chat_id_) then
            if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
              local id = msg.id_
              local msgs = {[0] = id}
              local chat = msg.chat_id_
              delete_msg(chat,msgs)
            end
          end
        end
	          if database:get('bot:english:ban'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
       chat_kick(msg.chat_id_, msg.sender_user_id_)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>اللغه الانكليزيه تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
          return 
   end
   
        if database:get('bot:english:warn'..msg.chat_id_) then
    local id = msg.id_
    local msgs = {[0] = id}
    local chat = msg.chat_id_
    local user_id = msg.sender_user_id_
       delete_msg(chat,msgs)
          send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>اللغه الانكليزيه تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
          return 
   end
     end
    end
   end
  if database:get('bot:cmds'..msg.chat_id_) and not is_vip(msg.sender_user_id_, msg.chat_id_) then
  return 
else

if text == 'رتبتي' and is_sudo(msg) then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  '🚨¦ رتبتك : اﻟ̣ـــمطور ماﻟ̣ـــتيے 🍃'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شوف' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '👀ششوف 👀'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شسمك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'اسمه اللمبــي 😹❤️' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شسمج' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'اسمها جعجوعه'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شسمها' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'لو اعرف اسمها جان مابقيت يمك/ج 😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شسمه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'لو اعرف اسمه جان مابقيت يمك/ج 😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'مرحبة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'منوؤؤ9ؤؤور/ة 🌝🌹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'خاص' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'شسوون بلخاص 😳😹 يي عمي شتغل الخاص'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'خاصك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'شسوون بلخاص 😳😹 يي عمي شتغل الخاص'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'خاصج' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'شسوون بلخاص 😳😹 يي عمي شتغل الخاص'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'غنيلي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'شتحب تسمع (راب_حزين_شعر_ردح_ردح حزين _ موال_ موسيقى ) \n كيفك انته وذوقك 😌❤️' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'راب' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'شكولك مال ثريد لاتخربها بلراب 😹❤️'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'حزين' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'اكو هواي مجروحين 😔 خاف غني وذكرهم'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ردح' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹😹😹تره رمضان قريب صلي صوم احسلك'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'موال' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🙁☝🏿️شكولي مال تحشيش ماخربها بلموال 😹❤️' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'موسيقى' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😒☝🏿️اكعد راحه بيتهوفن 😹 \n #اذا_ماتعرف_منو_بيتهوفن  \n #اكتب منو بيتهوفن'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'صباح الخير' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'صباحووو اشرقت وانورت 😌🍁' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'صباحو' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'صباحو اشرقت وانورت 😌🍁'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شنو رائيك بالشباب' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ' حبي من الاخير بطل زحف (عدى المطور ما يزحف)وربي ترة كبرت استحي ع كرشك يا ول😪بس رجائا لا تنظغط و تكلب جهرتك😒بس لا تتفيك و امشي عدل هنة يجنك😂 و ختاما سوي رجيم رجائا😂😂🚶🚨 والله من وجهة نظري امم🐸هي الصراحة لله و ما اريدة يزعل😪بس شسوي ما اكدر اظم بكلبي علية😂🚶 ' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'مساء الخير' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'مساء الخيرات اشرقت وانورت 😌🍁'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'مسائو' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'مسائو اشرقت وانورت 😌🍁'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'عركه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🙀يا الهي \n عركه اجيب 🏃🏻 السجاجين 🔪والمسدسات 🔫'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'عركة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🙀يا الهي \n عركه اجيب 🏃🏻 السجاجين 🔪والمسدسات 🔫'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ممكن' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'كضوووو راح يزحف 🙀😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تحبني' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'اشلون ماحبك/ج اذا انته/ي العشق مالي'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تعشقني' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😌☝🏿️اعشقكج لدرجه اذا خلوج بين 10 وردات اطلعج واني مغمض لان بس انتي الشوكه 😹\n #طــــن_تم_القصف'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'بوسني' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'امــــ💋💋ــــــوااااح'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'بوسه جبيره' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'امــــ💋💋ــــمـــ💋💋ــــمــــــ💋💋ــــمــــــــــــــــ💋💋ــــمــؤوووووواح 😹\n بهاي البوسه انسف وجهك/ج 😹😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'دوم' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '⌣{يـّـٌدِْۈۈ/عّزٌگ-ۈنَرﮔﺺّ بعرسك/ۈۈمْ}⌣'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🏻' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'خليك مضوجني 😹❤️'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'جاو' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'خليك مضوجني 😹❤️'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شنو رائيك بالبنات' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ' والله من وجهة نظري امم🐸هي الصراحة ولله و ما اريدهة تزعل /مني😂 بس راحت الجبهة راقب سيدي😂🚶🚨 بس سوال هاي بطنج لو حامل😂عمي سوي رجيم ل خاطر الله😒المهم اول مرة اشوف مسنفرة و سمينة 🐸تدرين اشبهج ب دبة الغاز😂🚶المهم شلونج😪🐸🚬😂🚶 ️' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'احجي علي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ' هذا/ه صاير وكح اشو 😪بس ولا يهمك سيدي  انت معليك😉بس جيب توثية و تونس😂👊وعوف الباقي علية😒😐 يا ول شو طالعة عينك😒 من البنات مو😪و هم صايرلك لسان تحجي😠اشو تعال👋👊صير حباب مرة ثانية ترةة ...😉و لا تخليني البسك عمامة و اتفل عليك😂 ' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'حبيبي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹☝🏿️ جذااااااااااااااااب موحبيبك'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ضلعي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😒☝🏿️مــاعندي ضلوع اني بوت'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ضلعتي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'هلا هلا اجن الضلوعات 😍😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'غبي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'انته الاغبه 😹😹😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تسلم' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'سالم راسك/ج😌❤️'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تسلمين' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'سالم راسك/ج😌❤️'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😀' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'عيوووون مال كوري 😹😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😬' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ضم سنونك/ج فضحتنه 🙀😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😂' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوم الضحكات عيوني 😍'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😂😂' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوم الضحكات عيوني 😍'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😂😂😂' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوم الضحكات عيوني 😍' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😹' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوم الضحكات عيوني 😍' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😹😹' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوم الضحكات عيوني 😍' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😃' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'فرحان/ه دووووم الفرحه ☺️😍'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😅' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'شبيك جنك واحد دايضربو ابره 😂'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😇' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'شيخ جامع'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😉' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'لتتحــارش/ين'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😊' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'انها احقر ابتسامه على وجه الكره الارضيه 😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🙂' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ابتسامه مال واحد مكتول كتله غسل ولبس 😍😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🙃' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'وجهة مكلوب أإأذأإأ هوه جميل 😌😍'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '☺️' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'خجلان الحلو/ة 😂 منو تحارش بيك/ج غيري 😌'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😋' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'جووووعان 😃'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😌' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'تواضع شويه 😒🔭' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😍' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'عيونه حمر عشكان/ة  الحلو/ة 😍😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شسمه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'لو اعرف اسمه جان مابقيت يمك/ج 😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😘' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ممنوع التقبيل في هذا الكروب 😹 هسه \nيزعلون الحدايق'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😗' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'بوووووسه مال عجوز 😝😂' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😚' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'عساس مستحي/ة بعد بست 😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😜' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ضم لسانك 😁 فضحتنه' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😝' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'غص الولد جيبوله ببسي دايت 😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😛' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'هذا مطلع لسانه كيوت 😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😐' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'عجوز في صدمه 😹☝🏿️'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🤐' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'عفيه لو هيج تخيط حلكك لو لا 😹😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'حاته' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'وينها خلي نرقمها 😍😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'حاتة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'وينها خلي نرقمها 😍😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'صاك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'وينه خلي اشمر عليه طماطه 😹😍'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'صاكة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'وينها خلي اكفش شعرها 😹😍'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🤔🤔' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'على كيفك انشتاين 😹🤘🏿'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '☹️' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'لاتحزن 🙁❤️ ف الله معك'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'منو هاي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'هَـ (⊙﹏⊙) ــاآي😝الراقصه مال اكروب💃😂'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اتفل' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '‏​‏​​​​​​‏​تـ💦😙ـف ‏​تِـٌ😙💦💦ـفين ‏​ثلاث تـ😗💦💦💦ـ فات‏​​​​ ‏​تف😙ــٌّوُفه ذغِيرَونهٌ ٌ 🌚💦 💦💦💦🌪💨💨💧💦🌊💦💦💦💦🌊💦💦🌊💦💦 اسـ.ــ..ــــــــحب اقسام خخخخخ تفوووو 💦💦💦💦💦💦💦💦💦💦💦💦💦💦💦🌊🌊💦💦🌊🌪💨💨🌪🌪🌊💦💧💦 خـٌٌـٌٌلُـِـِِ😁ــِِـِـُصُ عتاد😹🖐' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'خالتك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'هَـ (⊙﹏⊙) ــاآك😝افلوس💵جيبلي خالتك😂'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'رقم' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '❥בـلو בـلو اشـَ😡شـ😒ـكد😍حلو رقمي😍😂'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تنح' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ليش ماتجي اني انيجك😐وارفعك😈زاويه99واضربك ابواحد😲فراري 😂طوله من البصره😉لللانبار😂😆دي حدث هع' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '.' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ' لا❌لا يـا خـ{💩}ـره راح يـنـزل رابـط بـالـتـعـديـل 🍃☹️🖕🏼🚶️ ' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'يسلمو' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ' ولـ❁ٌٍِّﮩًٌٍُِّ﴿✞❀✞﴾ٌٍُِِِّ❁ــُؤؤؤِ  ✾❣تٍّْـٍّْ﴿💃﴾ٍّْـٍّْدٍّْلٍّْـٍّْ﴿👏﴾ٍّْـٍّْلٍّل/ين ' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ضوجه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'هاك فلوس 💵 حتى تفكك الضوجه 🤑🤑'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'نعال' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🙁☝🏿️ياعزيزي ليش تجاوز 😹 اله اسحلك/ج'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'احبنك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😌❤️ طبعا وتموت/ين  عليه هم'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'مرتي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'يعني عفت النسوان كلها جيت على مرتي 😡' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اشاقه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹😍 استمر هوه غير شقاك/ج الثكيل يخبل' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اشاقة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹😍 استمر هوه غير شقاك/ج الثكيل يخبل' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'غازله' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = ' امم اكف سيدي خلي اعدل روحي🐸اعدل القميص😂و اشرب مي ع مود صوتي طبعا😏يلا ح اغنيلة🐸🚬 كلبي يحب كل حلو🐸شلي ب الموحلو😏الموحلو شلي بي ما اريدة ما اسولف بي😂.. هاي بعدك ما مقتنع اوك😂🚬..حبيبي امك ما تقبل من احاجيك 🐸روحي معلكة بي😂🚶 ' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ههه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😍🙈شنوو هاي الضحكه لتخبل'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'هههه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوم الضحكات 😍🤘🏿' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اسمع' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'كوووووؤ👂🏿🌝👂🏿ؤؤؤؤؤل/ي سامعك/ج' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ورده' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🙈الي يمريني بورده ارمي بورده هيه والمزهريه   #ياخي_الكرم_واجب 😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'وردة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🙈الي يمريني بورده ارمي بورده هيه والمزهريه   #ياخي_الكرم_واجب 😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'فلوس' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'كبدي شتريد/ين فلوسك/ج  كاش لو شيك 🤔 ؟' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'كاش' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'هوه اني لو عندي كاش اصير بوت 😹 الله وكيلك نص ملفاتي بلدين 😹😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شيك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'هوه اني لو عندي شيك  اصير بوت 😹 الله وكيلك نص ملفاتي بلدين 😹😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'سياره' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹☝🏿️ ت ريد/ين سياره هوه انته/ي بايسكل كل مترين تضرب دقله 😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'سيارة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹☝🏿️ تريد/ين سياره هوه انته/ي بايسكل كل مترين تضرب دقله 😹' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'موعد غرامي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😍موعد غرامي اسف متواعد 😹❤️' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ملابس' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🌚☝🏿️ تريدهن من المول لو من باله ؟' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'مول' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹☝🏿️يريد يقطني ماشتريلك لوتموت' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'باله' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹☝🏿️ موحلوات عليك هم ماشتريلك' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'بالة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹☝🏿️ موحلوات عليك هم ماشتريلك' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زاحف' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'لتشوؤف الناس بعين طبعك 😹😍  \n #في_منتصف_الجبهة_تم_القصف 😂'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زاحفه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ماخرب الشباب الطيبه غيرجن 😹 شنووو علاججن'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زاحفة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ماخرب الشباب الطيبه غيرجن 😹 شنووو علاججن'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زباله' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'لاتقلط 😤🔫 لو الا  ازرف بيتكم' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زبالة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'لاتقلط 😤🔫 لو الا  ازرف بيتكم' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'انجب' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '☹️☝🏿️ هــاااااي عليه مو'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'انجبي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '☹️☝️ ️🏿️ هــاااااي عليها مو' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اهو' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹 ليش ولك/ج خطيه هذا/ه 😿 لاتكول اهوو' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اهوو' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹 ليش ولك/ج خطيه هذا/ه 😿 لاتكول اهوو' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اهووو' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹 ليش ولك/ج خطيه هذا/ه 😿 لاتكول اهوو' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تخليني' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😈اخليكّْ بزوايـﮧ 90 وتعرف الباﻗ̮ـ̃ي امﺷ͠ي لكّْ زاحف🐢🐍🐍' 
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ابوك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'عـــ👴🏽ـوف/ي لحجي 🤑 بحــاله'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ابوج' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'عـــ👴🏽ـوف/ي لحجي 🤑 بحــاله'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'امك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🤑 عــ👵🏻ــؤف الحجيه بحالها'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'امج' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🤑 عــ👵🏻ــؤف الحجيه بحالها'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اختك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹☝🏿️حظرو سجاجينكم 🔪جابو سيره الخوات راح تصير عركه'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اختج' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😹☝🏿️حظرو سجاجينكم 🔪جابو سيره الخوات راح تصير عركه'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اخوك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🌝😹 هووووه اني جيت للكروب داخلص منه شسوي/ن  بي  انته/ي'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اخوج' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '🌝😹 هووووه اني جيت للكروب داخلص منه شسوي/ن  بي  انته/ي'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'بخير' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '😌🐾 ياااااااارب الى الأفضل'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'منور' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'نــؤؤؤ99ؤؤؤرك/ج  حرڰ وجهي 🌚😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'منوره' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'نــؤؤؤ99ؤؤؤرك/ج  حرڰ وجهي 🌚😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'منورة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'نــؤؤؤ99ؤؤؤرك/ج  حرڰ وجهي 🌚😹'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اخباركم' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'احنه تمام احجيلنه انته/ي شلوونك/ج 😌'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زين' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوؤؤؤمــــ😌🐾ــــــك/ج'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زينه' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوؤؤؤمــــ😌🐾ــــــك/ج'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'زينة' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'دوؤؤؤمــــ😌🐾ــــــك/ج'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'احبك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ﯠآݩـ✥ـٍﻲ ﻫـݥ يأڸݦـ✥ـٍ؏ـذبــ๋͜ني😻❣'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'هلو' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'هــ๋͜ݪآﯠآت يـ✥ـٍاپ😻🍃'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'السلام عليكم' or text == 'سلام عليكم' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ﯠݞـلـ✥ـٍيكــ๋͜م ݩـﯡرﻳــ๋͜ت😽👏'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'الحمدلله' or text == 'الحمد لله' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ݟـسـ✥ـٍاڪ ﮔلـ✥ـٍﻴــ๋͜بي😸👊'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'مرحبا' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ݥـݛاحـ✥ـٍب ۿـݪأ ﯠﷲ🙀💙'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'هاي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ۿـآيـ✥ـٍات بحــ๋͜ي😼👀'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شلونكم' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ٻـﺨــ๋͜يـݛ وآݩـ✥ـٍݓ ڜلــ๋͜وݨك😽🙌'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'بوت' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'آيي گــ๋͜وڸ/ي حـ✥ـٍبي راﻳـ✥ـٍد/ه ﺷـ✥ـٍيي😼👏'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'هلاو' then  
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'هــ๋͜ݪآﯠآت يـ✥ـٍاپ😻🍃'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تشاكي' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ۿـ✥ـٍا ۺـتݛﻳـد😼🤞'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شلونك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ﮊﻳـ✥ـٍݩ ﯠانـ✥ـٍته/ي😺✨'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'جاو' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ﷲ ﯠﻳـ✥ـٍاك/ج حبـٍي😼🙌'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'باي' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ﺗـ✥ـٍريــ๋͜له ݑـݪآ ݛقـ✥ـٍم😽👐'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اكرهك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'آﯠﮔ ﯠانـ✥ـٍي ۿـݥ😹🙌'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تكرهني' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'ݦــ๋͜آدݬي😹💔'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اعشقك' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'الـ✥ـٍظاۿر ݥـعــ๋͜وز/ة😹💔'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شخباركم' then 
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody =  'تـ✥ـٍماݥ ݥــ๋͜ـاۺي الحـ✥ـٍال وانتـ✥ـٍ/ي😼🙌'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'اكلك' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ۿـآ ڜـ✥ـٍكو ﮔوڷ🙀⚡️'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'شوف' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ۺـڜــ๋͜وف😼🤞؟'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'ها' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ﯠجعـ✥ـٍآ وﻃـآﮔر حـ✥ـٍا😹🙌'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == 'تمام' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ډﯠمـ✥ـٍك حُب ۶ـمـ✥ـٍري😽💞'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '🙄' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = '۶ـينڪ ﯠلـ✥ـٍك😼👊'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text == '😒' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'ډﻳﻴﻴﻴﻴﻴـ✥ـٍﻲ😼🐎'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
if text  == '🚶🏻🍃' then
if not database:get('bot:rep:mute'..msg.chat_id_) then
moody = 'بـ✥ـٍا؏ الۿــ๋͜يبـﮩﮧ😽💗'
else 
moody = ''
end
send(msg.chat_id_, msg.id_, 1, moody, 1, 'md')
end
    ------------------------------------ With Pattern -------------------------------------------
	if text:match("^[Ll][Ee][Aa][Vv][Ee]$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
    
	if text:match("^مغادره$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	     chat_leave(msg.chat_id_, bot_id)
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('رفع ادمن','setmote')
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee]$")  and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already moderator._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم رفعه ادمن` ☑️', 1, 'md')
              end
            else
         database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _promoted as moderator._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم رفعه ادمن` ☑️', 1, 'md')
              end
	end 
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Mm][Oo][Tt][Ee]) @(.*)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:mods:'..msg.chat_id_, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User '..result.id_..' promoted as moderator.!</code>'
          else
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم رفعه ادمن</code> ☑️'
            end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Mm][Oo][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Mm][Oo][Tt][Ee]) (%d+)$")} 	
	        database:sadd('bot:mods:'..msg.chat_id_, apmd[2])
          if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _promoted as moderator._', 1, 'md')
          else
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apmd[2]..'* `تم رفعه ادمن` ☑️', 1, 'md')
          end
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('تنزيل ادمن','remmote')
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:mods:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Promoted._', 1, 'md')
              else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم تنزيله من الادمنيه` 💯️', 1, 'md')
              end
	else
         database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then

         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Demoted._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم تنزيله من الادمنيه` 💯️', 1, 'md')
	end
  end
  end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Mm][Oo][Tt][Ee]) @(.*)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Demoted</b>'
          else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم تنزيله من الادمنيه</code> 💯️'
    end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>💯️'
        end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Mm][Oo][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:mods:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Mm][Oo][Tt][Ee]) (%d+)$")} 	
         database:srem(hash, apmd[2])
              if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _Demoted._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apmd[2]..'* `تم تنزيله من الادمنيه` 💯️', 1, 'md')
  end
  end
  -----------------------------------------------------------------------------------------------
if msg.content_.entities_ then
if msg.content_.entities_[0] then
if msg.content_.entities_[0] and msg.content_.entities_[0].ID == "MessageEntityUrl" or msg.content_.entities_[0].ID == "MessageEntityTextUrl" then
if database:get('bot:markdown:mute'..msg.chat_id_) then
  delete_msg(msg.chat_id_, {[0] = msg.id_})
end
if database:get('bot:markdown:ban'..msg.chat_id_) then
delete_msg(msg.chat_id_, {[0] = msg.id_})
chat_kick(msg.chat_id_, msg.sender_user_id_)
  send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الماركدون تم قفلها ممنوع ارسالها</code> 💯️\n✦┇ﮧ  <code>تم طردك</code> ❌", 1, 'html')
end
if database:get('bot:markdown:warn'..msg.chat_id_) then
delete_msg(msg.chat_id_, {[0] = msg.id_})
  send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>الايدي 📍 : </code><code>"..msg.sender_user_id_.."</code>\n✦┇ﮧ  <code>الماركدون تم قفلها ممنوع ارسالها</code> 💯️❌", 1, 'html')
end
if msg.forward_info_ then
if database:get('bot:forward:mute'..msg.chat_id_) then
 if msg.forward_info_.ID == "MessageForwardedFromUser" or msg.forward_info_.ID == "MessageForwardedPost" then
delete_msg(msg.chat_id_, {[0] = msg.id_})
end
end
end
end
end
end

  -----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('رفع عضو مميز','setvip')
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp]$")  and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function promote_by_reply(extra, result, success)
	local hash = 'bot:vipgp:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already vip._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم رفعه عضو مميز` ☑️', 1, 'md')
              end
            else
         database:sadd(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _promoted as vip._', 1, 'md')
              else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم رفعه عضو مميز` ☑️', 1, 'md')
              end
	end 
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,promote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Vv][Ii][Pp]) @(.*)$")} 
	function promote_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:vipgp:'..msg.chat_id_, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User '..result.id_..' promoted as vip.!</code>'
          else
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم رفعه عضو مميز</code> ☑️'
            end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],promote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Vv][Ii][Pp] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apmd = {string.match(text, "^([Ss][Ee][Tt][Vv][Ii][Pp]) (%d+)$")} 	
	        database:sadd('bot:vipgp:'..msg.chat_id_, apmd[2])
          if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _promoted as vip._', 1, 'md')
          else
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apmd[2]..'* `تم رفعه عضو مميز` ☑️', 1, 'md')
          end
    end
	-----------------------------------------------------------------------------------------------
        local text = msg.content_.text_:gsub('تنزيل عضو مميز','remvip')
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function demote_by_reply(extra, result, success)
	local hash = 'bot:vipgp:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
              if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Promoted vip._', 1, 'md')
              else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم تنزيله من الاعضاء المميزين` 💯️', 1, 'md')
              end
	else
         database:srem(hash, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then

         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Demoted vip._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم تنزيله من الاعضاء المميزين` 💯️', 1, 'md')
	end
  end
  end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,demote_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:vipgp:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Vv][Ii][Pp]) @(.*)$")} 
	function demote_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Demoted vip</b>'
          else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم تنزيله من الاعضاء المميزين</code> 💯️'
    end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>💯️'
        end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apmd[2],demote_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Vv][Ii][Pp] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:vipgp:'..msg.chat_id_
	local apmd = {string.match(text, "^([Rr][Ee][Mm][Vv][Ii][Pp]) (%d+)$")} 	
         database:srem(hash, apmd[2])
              if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apmd[2]..'* _Demoted vip._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apmd[2]..'* `تم تنزيله من الاعضاء المميزين` 💯️', 1, 'md')
  end
  end
  
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('حظر','Ban')
	if text:match("^[Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function ban_by_reply(extra, result, success)
	local hash = 'bot:banned:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حظر الادمنيه والمدراء 💯️❌', 1, 'md')
end
    else
    if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Banned._', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم حظره` 💯️', 1, 'md')
end
		 chat_kick(result.chat_id_, result.sender_user_id_)
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Banned._', 1, 'md')
       else
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم حظره` 💯️', 1, 'md')
end
		 chat_kick(result.chat_id_, result.sender_user_id_)
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,ban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Bb][Aa][Nn]) @(.*)$")} 
	function ban_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حظر الادمنيه والمدراء 💯️❌', 1, 'md')
end
    else
	        database:sadd('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Banned.!</b>'
else
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم حظره</code> 💯️'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apba[2],ban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Bb][Aa][Nn]) (%d+)$")}
	if is_mod(apba[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حظر الادمنيه والمدراء 💯️❌', 1, 'md')
end
    else
	        database:sadd('bot:banned:'..msg.chat_id_, apba[2])
		 chat_kick(msg.chat_id_, apba[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apba[2]..'* _Banned._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apba[2]..'* `تم حظره` 💯️', 1, 'md')
  	end
	end
end
  ----------------------------------------------unban--------------------------------------------
          local text = msg.content_.text_:gsub('الغاء حظر','unban')
  	if text:match("^[Uu][Nn][Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unban_by_reply(extra, result, success) 
	local hash = 'bot:banned:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Banned._', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم الغاء حظره` ☑️', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Unbanned._', 1, 'md')
       else
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم الغاء حظره` ☑️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unban_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Bb][Aa][Nn] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn]) @(.*)$")} 
	function unban_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:banned:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Unbanned.!</b>'
      else
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم الغاء حظره</code> ☑️'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apba[2],unban_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Bb][Aa][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apba = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn]) (%d+)$")} 	
	        database:srem('bot:banned:'..msg.chat_id_, apba[2])
        if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apba[2]..'* _Unbanned._', 1, 'md')
else
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apba[2]..'* `تم الغاء حظره` ☑️', 1, 'md')
end
  end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('حذف الكل','delall')
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll]$") and is_owner(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function delall_by_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حذف رسائل الادمنيه والمدراء 💯️❌', 1, 'md')
end
else
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..result.sender_user_id_..'* _Has been deleted!!_', 1, 'md')
       else
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم حذف كل رسائله` 💯️', 1, 'md')
end
		     del_all_msgs(result.chat_id_, result.sender_user_id_)
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,delall_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
		local ass = {string.match(text, "^([Dd][Ee][Ll][Aa][Ll][Ll]) (%d+)$")} 
	if is_mod(ass[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حذف رسائل الادمنيه والمدراء 💯️❌', 1, 'md')
end
else
	 		     del_all_msgs(msg.chat_id_, ass[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_All Msgs from _ *'..ass[2]..'* _Has been deleted!!_', 1, 'md')
       else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..ass[2]..'* `تم حذف كل رسائله` 💯️', 1, 'md')
end    end
	end
 -----------------------------------------------------------------------------------------------
	if text:match("^[Dd][Ee][Ll][Aa][Ll][Ll] @(.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local apbll = {string.match(text, "^([Dd][Ee][Ll][Aa][Ll][Ll]) @(.*)$")} 
	function delall_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t Delete Msgs from Moderators!!*', 1, 'md')
else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حذف رسائل الادمنيه والمدراء 💯️❌', 1, 'md')
end
return false
    end
		 		     del_all_msgs(msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>All Msg From user</b> <code>'..result.id_..'</code> <b>Deleted!</b>'
          else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم حذف كل رسائله</code> 💯️'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apbll[2],delall_by_username)
    end
  -----------------------------------------banall--------------------------------------------------
          local text = msg.content_.text_:gsub('حظر عام','banall')
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
            function gban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
	if is_admin(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حظر ادمنيه البوت والمطورين عام 💯️❌', 1, 'md')
end
    else
              database:sadd(hash, result.sender_user_id_)
              chat_kick(result.chat_id_, result.sender_user_id_)
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Banned !</b>'
                else
                  texts = '✦┇ﮧ  <code>العضو </code>'..result.sender_user_id_..'<code> تم حظره عام</code> 💯️'
end
end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
          end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,gban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Bb][Aa][Nn][Aa][Ll][Ll]) @(.*)$")}
            function gban_by_username(extra, result, success)
              if result.id_ then
         	if is_admin(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
            send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حظر ادمنيه البوت والمطورين عام 💯️❌', 1, 'md')
end
  else
              local hash = 'bot:gbanned:'
                if database:get('lang:gp:'..msg.chat_id_) then
                texts = '<b>User :</b> <code>'..result.id_..'</code> <b> Has been Globally Banned !</b>'
              else 
                texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم حظره عام</code> 💯️'
end
                database:sadd(hash, result.id_)
                end
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User not found!</b>'
                else
                  texts = '<code>خطا </code>💯️'
                end
            end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(apbll[2],gban_by_username)
          end
          
          if text:match("^[Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Bb][Aa][Nn][Aa][Ll][Ll]) (%d+)$")}
  local hash = 'bot:gbanned:'
	if is_admin(apbll[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Banall] admins/sudo!!*', 1, 'md')
       else
            send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع حظر ادمنيه البوت والمطورين عام 💯️❌', 1, 'md')
end
    else
	        database:sadd(hash, apbll[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apbll[2]..'* _Has been Globally Banned _', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apbll[2]..'* `تم حظره عام` 💯️', 1, 'md')
  	end
	end
end
          -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('الغاء العام','unbanall')
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
            function ungban_by_reply(extra, result, success)
              local hash = 'bot:gbanned:'
              if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User :</b> '..result.sender_user_id_..' <b>Has been Globally Unbanned !</b>'
             else
                  texts =  '✦┇ﮧ  <code>العضو '..result.sender_user_id_..' تم الغاء حظره من العام </code> ☑️'
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
              database:srem(hash, result.sender_user_id_)
            end
            getMessage(msg.chat_id_, msg.reply_to_message_id_,ungban_by_reply)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apid = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]) @(.*)$")}
            function ungban_by_username(extra, result, success)
              local hash = 'bot:gbanned:'
              if result.id_ then
                if database:get('lang:gp:'..msg.chat_id_) then
                 texts = '<b>User :</b> '..result.id_..' <b>Has been Globally Unbanned !</b>'
                else
                texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم الغاء حظره من العام</code> ☑️'
                end
                database:srem(hash, result.id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  texts = '<b>User not found!</b>'
                else 
                  texts = '<code>خطا </code>💯️'
                        end
              end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
            resolve_username(apid[2],ungban_by_username)
          end
          -----------------------------------------------------------------------------------------------
          if text:match("^[Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
            local apbll = {string.match(text, "^([Uu][Nn][Bb][Aa][Nn][Aa][Ll][Ll]) (%d+)$")}
            local hash = 'bot:gbanned:'
              database:srem(hash, apbll[2])
              if database:get('lang:gp:'..msg.chat_id_) then
              texts = '<b>User :</b> '..apbll[2]..' <b>Has been Globally Unbanned !</b>'
            else 
                texts = '✦┇ﮧ  <code>العضو </code>'..apbll[2]..'<code> تم الغاء حظره من العام</code> ☑️'
end
              send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
            end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('كتم','silent')
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function mute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if is_mod(result.sender_user_id_, result.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `لا تستطيع كتم الادمنيه والمدراء` 💯️❌', 1, 'md')
end
    else
    if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already silent._', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم كتمه` 💯️', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _silent_', 1, 'md')
       else 
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم كتمه` 💯️', 1, 'md')
end
	end
    end
	end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,mute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Ss][Ii][Ll][Ee][Nn][Tt]) @(.*)$")} 
	function mute_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `لا تستطيع كتم الادمنيه والمدراء` 💯️❌', 1, 'md')
end
    else
	        database:sadd('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>silent</b>'
          else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم كتمه</code> 💯️'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
              if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apsi[2],mute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Ss][Ii][Ll][Ee][Nn][Tt]) (%d+)$")}
	if is_mod(apsi[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick/Ban] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `لا تستطيع كتم الادمنيه والمدراء` 💯️❌', 1, 'md')
end
    else
	        database:sadd('bot:muted:'..msg.chat_id_, apsi[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apsi[2]..'* _silent_', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apsi[2]..'* `تم كتمه` 💯️', 1, 'md')
end
	end
    end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('الغاء كتم','unsilent')
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) and msg.reply_to_message_id_ then
	function unmute_by_reply(extra, result, success)
	local hash = 'bot:muted:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not silent._', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم الغاء كتمه` ☑️', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _unsilent_', 1, 'md')
       else 
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم الغاء كتمه` ☑️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,unmute_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]) @(.*)$")} 
	function unmute_by_username(extra, result, success)
	if result.id_ then
         database:srem('bot:muted:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>unsilent.!</b>'
          else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم الغاء كتمه</code> ☑️'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apsi[2],unmute_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apsi = {string.match(text, "^([Uu][Nn][Ss][Ii][Ll][Ee][Nn][Tt]) (%d+)$")} 	
	        database:srem('bot:muted:'..msg.chat_id_, apsi[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apsi[2]..'* _unsilent_', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apsi[2]..'* `تم الغاء كتمه` ☑️', 1, 'md')
end
  end
    -----------------------------------------------------------------------------------------------
    local text = msg.content_.text_:gsub('طرد','kick')
  if text:match("^[Kk][Ii][Cc][Kk]$") and msg.reply_to_message_id_ and is_mod(msg.sender_user_id_, msg.chat_id_) then
      function kick_reply(extra, result, success)
	if is_mod(result.sender_user_id_, result.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `لا تستطيع طرد الادمنيه والمدراء` 💯️❌', 1, 'md')
end
  else
                if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*User* _'..result.sender_user_id_..'_ *Kicked.*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` '..result.sender_user_id_..' `تم طرده` 💯️', 1, 'md')
end
        chat_kick(result.chat_id_, result.sender_user_id_)
        end
	end
   getMessage(msg.chat_id_,msg.reply_to_message_id_,kick_reply)
  end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Kk][Ii][Cc][Kk] @(.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apki = {string.match(text, "^([Kk][Ii][Cc][Kk]) @(.*)$")} 
	function kick_by_username(extra, result, success)
	if result.id_ then
	if is_mod(result.id_, msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع طرد الادمنيه والمدراء 💯️❌', 1, 'md')
end
    else
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Kicked.!</b>'
else
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم طرده</code> 💯️'
end
		 chat_kick(msg.chat_id_, result.id_)
	end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apki[2],kick_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Kk][Ii][Cc][Kk] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local apki = {string.match(text, "^([Kk][Ii][Cc][Kk]) (%d+)$")}
	if is_mod(apki[2], msg.chat_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*You Can,t [Kick] Moderators!!*', 1, 'md')
       else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  لا تستطيع طرد الادمنيه والمدراء 💯️❌', 1, 'md')
end
    else
		 chat_kick(msg.chat_id_, apki[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apki[2]..'* _Kicked._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apki[2]..'* `تم طرده` 💯️', 1, 'md')
  	end
	end
end
          -----------------------------------------------------------------------------------------------
 local text = msg.content_.text_:gsub('اضافه','invite')
   if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee]$") and msg.reply_to_message_id_ ~= 0 and is_sudo(msg) then
   function inv_reply(extra, result, success)
    add_user(result.chat_id_, result.sender_user_id_, 5)
                if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*User* _'..result.sender_user_id_..'_ *Add it.*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` '..result.sender_user_id_..' `تم اضافته للمجموعه` ☑️', 1, 'md')
   end
   end
    getMessage(msg.chat_id_, msg.reply_to_message_id_,inv_reply)
   end
          -----------------------------------------------------------------------------------------------
   if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee] @(.*)$") and is_sudo(msg) then
    local apss = {string.match(text, "^([Ii][Nn][Vv][Ii][Tt][Ee]) @(.*)$")}
    function invite_by_username(extra, result, success)
     if result.id_ then
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Add it!</b>'
else
            texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم اضافته للمجموعه</code> ☑️'
end
    add_user(msg.chat_id_, result.id_, 5)
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else
            texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
    resolve_username(apss[2],invite_by_username)
 end
        -----------------------------------------------------------------------------------------------
    if text:match("^[Ii][Nn][Vv][Ii][Tt][Ee] (%d+)$") and is_sudo(msg) then
      local apee = {string.match(text, "^([Ii][Nn][Vv][Ii][Tt][Ee]) (%d+)$")}
      add_user(msg.chat_id_, apee[2], 5)
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apee[2]..'* _Add it._', 1, 'md')
else
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apee[2]..'* `تم اضافته للمجموعه` ☑️', 1, 'md')
  	end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('رفع مدير','setowner')
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function setowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if database:sismember(hash, result.sender_user_id_) then
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Owner._', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم رفعه مدير` ☑️', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Promoted as Group Owner._', 1, 'md')
       else 
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم رفعه مدير` ☑️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,setowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) @(.*)$")} 
	function setowner_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:owners:'..msg.chat_id_, result.id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Promoted as Group Owner.!</b>'
          else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم رفعه مدير</code> ☑️'
end
          else 
                  if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apow[2],setowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Ss][Ee][Tt][Oo][Ww][Nn][Ee][Rr]) (%d+)$")} 	
	        database:sadd('bot:owners:'..msg.chat_id_, apow[2])
                  if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apow[2]..'* _Promoted as Group Owner._', 1, 'md')
else 
   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apow[2]..'* `تم رفعه مدير` ☑️', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تنزيل مدير','remowner')
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]$") and is_admin(msg.sender_user_id_) and msg.reply_to_message_id_ then
	function deowner_by_reply(extra, result, success)
	local hash = 'bot:owners:'..msg.chat_id_
	if not database:sismember(hash, result.sender_user_id_) then
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Owner._', 1, 'md')
    else 
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم تنزيله من المدراء` 💯️', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
                  if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Removed from ownerlist._', 1, 'md')
       else 
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم تنزيله من المدراء` 💯️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deowner_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] @(.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local apow = {string.match(text, "^([Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]) @(.*)$")} 
	local hash = 'bot:owners:'..msg.chat_id_
	function remowner_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Removed from ownerlist</b>'
     else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم تنزيله من المدراء</code> 💯️'
end
          else 
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(apow[2],remowner_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:owners:'..msg.chat_id_
	local apow = {string.match(text, "^([Rr][Ee][Mm][Oo][Ww][Nn][Ee][Rr]) (%d+)$")} 	
         database:srem(hash, apow[2])
	     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..apow[2]..'* _Removed from ownerlist._', 1, 'md')
else 
    send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..apow[2]..'* `تم تنزيله من المدراء` 💯️', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
	          local text = msg.content_.text_:gsub('رفع ادمن للبوت','setadmin')
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
	function addadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:' 
	if database:sismember(hash, result.sender_user_id_) then
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is Already Admin._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم رفعه ادمن للبوت` ☑️', 1, 'md')
end
	else
         database:sadd(hash, result.sender_user_id_)
	     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Added to admins._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم رفعه ادمن للبوت` ☑️', 1, 'md')
end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,addadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local ap = {string.match(text, "^([Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]) @(.*)$")} 
	function addadmin_by_username(extra, result, success)
	if result.id_ then
	        database:sadd('bot:admins:', result.id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Added to admins.!</b>'
          else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم رفعه ادمن للبوت</code> ☑️'
end
          else 
	     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],addadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local ap = {string.match(text, "^([Ss][Ee][Tt][Aa][Dd][Mm][Ii][Nn]) (%d+)$")} 	
	        database:sadd('bot:admins:', ap[2])
		     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..ap[2]..'* _Added to admins._', 1, 'md')
else 
  	send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..ap[2]..'* `تم رفعه ادمن للبوت` ☑️', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تنزيل ادمن للبوت','remadmin')
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) and msg.reply_to_message_id_ then
	function deadmin_by_reply(extra, result, success)
	local hash = 'bot:admins:'
	if not database:sismember(hash, result.sender_user_id_) then
		     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _is not Admin._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `بالفعل تم تنزيله من ادمنيه البوت` 💯️', 1, 'md')
end
	else
         database:srem(hash, result.sender_user_id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_User_ *'..result.sender_user_id_..'* _Removed from Admins!._', 1, 'md')
       else 
  	send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..result.sender_user_id_..'* `تم تنزيله من ادمنيه البوت` 💯️', 1, 'md')

end
	end
    end
	      getMessage(msg.chat_id_, msg.reply_to_message_id_,deadmin_by_reply)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] @(.*)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^([Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]) @(.*)$")} 
	function remadmin_by_username(extra, result, success)
	if result.id_ then
         database:srem(hash, result.id_)
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<b>User </b><code>'..result.id_..'</code> <b>Removed from Admins!</b>'
          else 
                        texts = '✦┇ﮧ  <code>العضو </code>'..result.id_..'<code> تم تنزيله من ادمنيه البوت</code> 💯️'
end
          else 
		     if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
                        texts = '<code>خطا </code>💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],remadmin_by_username)
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn] (%d+)$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local hash = 'bot:admins:'
	local ap = {string.match(text, "^([Rr][Ee][Mm][Aa][Dd][Mm][Ii][Nn]) (%d+)$")} 	
         database:srem(hash, ap[2])
		     if database:get('lang:gp:'..msg.chat_id_) then
	send(msg.chat_id_, msg.id_, 1, '_User_ *'..ap[2]..'* Removed from Admins!_', 1, 'md')
else 
  	send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `العضو` *'..ap[2]..'* `تم تنزيله من ادمنيه البوت` 💯️', 1, 'md')
end
    end 
	-----------------------------------------------------------------------------------------------
	if text:match("^[Mm][Oo][Dd][Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^الادمنيه$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:mods:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Mod List:</b>\n\n"
else 
  text = "✦┇ﮧ  <code>قائمه الادمنيه </code>⬇️ :\n\n"
  end
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد ادمنيه</code> 💯️"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

	if text:match("^[Vv][Ii][Pp][Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^الاعضاء المميزين") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:vipgp:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Vip List:</b>\n\n"
else 
  text = "✦┇ﮧ  <code>قائمه الاعضاء المميزين </code>⬇️ :\n\n"
  end
	for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Vip List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد اعضاء مميزين</code> 💯️"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
  end

	if text:match("^[Bb][Aa][Dd][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^قائمه المنع$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local hash = 'bot:filters:'..msg.chat_id_
      if hash then
         local names = database:hkeys(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>bad List:</b>\n\n"
else 
  text = "✦┇ﮧ  <code>قائمه الكلمات الممنوعه </code>⬇️ :\n\n"
  end    for i=1, #names do
      text = text..'> `'..names[i]..'`\n'
    end
	if #names == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>bad List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد كلمات ممنوعه</code> 💯️"
end
    end
		  send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
       end 
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ii][Ll][Ee][Nn][Tt][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^المكتومين$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:muted:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Silent List:</b>\n\n"
else 
  text = "✦┇ﮧ  <code>قائمه المكتومين </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Mod List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد مكتومين</code> 💯️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Oo][Ww][Nn][Ee][Rr][Ss]$") and is_sudo(msg) or text:match("^[Oo][Ww][Nn][Ee][Rr][Ll][Ii][Ss][Tt]$") and is_sudo(msg) or text:match("^المدراء$") and is_sudo(msg) then
    local hash =  'bot:owners:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>owner List:</b>\n\n"
else 
  text = "✦┇ﮧ  <code>قائمه المدراء </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>owner List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد مدراء</code> 💯️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^المحظورين$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local hash =  'bot:banned:'..msg.chat_id_
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>ban List:</b>\n\n"
else 
  text = "✦┇ﮧ  <code>قائمه المحظورين </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>ban List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد محظورين</code> 💯️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

  if msg.content_.text_:match("^[Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or msg.content_.text_:match("^قائمه العام$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    local hash =  'bot:gbanned:'
    local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Gban List:</b>\n\n"
else 
  text = "✦┇ﮧ  <code>قائمه الحظر العام </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
    local user_info = database:hgetall('user:'..v)
    if user_info and user_info.username then
    local username = user_info.username
      text = text..k.." - @"..username.." ["..v.."]\n"
      else
      text = text..k.." - "..v.."\n"
          end
end
            if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Gban List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد محظورين عام</code> 💯️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Aa][Dd][Mm][Ii][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^ادمنيه البوت$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    local hash =  'bot:admins:'
	local list = database:smembers(hash)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Admin List:</b>\n\n"
else 
  text = "✦┇ﮧ  <code>قائمه ادمنيه البوت </code>⬇️ :\n\n"
end	
for k,v in pairs(list) do
	local user_info = database:hgetall('user:'..v)
		if user_info and user_info.username then
			local username = user_info.username
			text = text..k.." - @"..username.." ["..v.."]\n"
		else
			text = text..k.." - "..v.."\n"
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Admin List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد ادمنيه للبوت</code> 💯️"
end
end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[Ii][Dd]$") or text:match("^ايدي$") and msg.reply_to_message_id_ ~= 0 then
      function id_by_reply(extra, result, success)
	  local user_msgs = database:get('user:msgs'..result.chat_id_..':'..result.sender_user_id_)
        send(msg.chat_id_, msg.id_, 1, "`"..result.sender_user_id_.."`", 1, 'md')
        end
   getMessage(msg.chat_id_, msg.reply_to_message_id_,id_by_reply)
  end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('ايدي','id')
    if text:match("^[Ii][Dd] @(.*)$") then
	local ap = {string.match(text, "^([Ii][Dd]) @(.*)$")} 
	function id_by_username(extra, result, success)
	if result.id_ then
            texts = '<code>'..result.id_..'</code>'
          else 
           if database:get('lang:gp:'..msg.chat_id_) then
            texts = '<code>User not found!</code>'
          else 
            texts = '<code>خطا </code> 💯️'
end
    end
	         send(msg.chat_id_, msg.id_, 1, texts, 1, 'html')
    end
	      resolve_username(ap[2],id_by_username)
    end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('جلب صوره','getpro')
    if text:match("^getpro (%d+)$") and msg.reply_to_message_id_ == 0  then
		local pronumb = {string.match(text, "^(getpro) (%d+)$")} 
local function gpro(extra, result, success)
--vardump(result)
   if pronumb[2] == '1' then
   if result.photos_[0] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '2' then
   if result.photos_[1] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[1].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 2 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 2 في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '3' then
   if result.photos_[2] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[2].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 3 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 3 في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '4' then
      if result.photos_[3] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[3].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 4 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 4 في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '5' then
   if result.photos_[4] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[4].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 5 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 5 في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '6' then
   if result.photos_[5] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[5].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 6 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 6 في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '7' then
   if result.photos_[6] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[6].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 7 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 7 في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '8' then
   if result.photos_[7] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[7].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 8 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 8 في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '9' then
   if result.photos_[8] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[8].sizes_[1].photo_.persistent_id_)
   else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt 9 Profile Photo!!", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 9 في حسابك` 💯️", 1, 'md')
end
   end
   elseif pronumb[2] == '10' then
   if result.photos_[9] then
      sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[9].sizes_[1].photo_.persistent_id_)
   else
                     if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "_You Have'nt 10 Profile Photo!!_", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا تملك صوره 10 في حسابك` 💯️", 1, 'md')
end
   end
 else
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*I just can get last 10 profile photos!:(*", 1, 'md')
    else 
            send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `لا استطيع جلب اكثر من 10 صور` 💯️", 1, 'md')
end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = pronumb[2]
  }, gpro, nil)
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع تكرار بالطرد','flood ban')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Bb][Aa][Nn] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Bb][Aa][Nn]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
else
           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ضع عدد من  *[2]* الى [_99999_]` 💯️', 1, 'md')
end
	else
    database:set('flood:max:'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood has been set to_ *'..floodmax[2]..'*', 1, 'md')
        else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع التكرار بالطرد للعدد` ✓⬅️ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end

          local text = msg.content_.text_:gsub('وضع تكرار بالكتم','flood mute')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Mm][Uu][Tt][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Mm][Uu][Tt][Ee]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ضع عدد من  *[2]* الى [_99999_]` 💯️', 1, 'md')
end
	else
    database:set('flood:max:warn'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood Warn has been set to_ *'..floodmax[2]..'*', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع التكرار بالكتم للعدد` ✓⬅️ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end
          local text = msg.content_.text_:gsub('وضع تكرار بالمسح','flood del')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Dd][Ee][Ll] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodmax = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Dd][Ee][Ll]) (%d+)$")} 
	if tonumber(floodmax[2]) < 2 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ضع عدد من  *[2]* الى [_99999_]` 💯️', 1, 'md')
end
	else
    database:set('flood:max:del'..msg.chat_id_,floodmax[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood delete has been set to_ *'..floodmax[2]..'*', 1, 'md')
       else 
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع التكرار بالمسح للعدد` ✓⬅️ : *'..floodmax[2]..'*', 1, 'md')
end
	end
end
          local text = msg.content_.text_:gsub('وضع كلايش بالمسح','spam del')
if text:match("^[Ss][Pp][Aa][Mm] [Dd][Ee][Ll] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
local sensspam = {string.match(text, "^([Ss][Pp][Aa][Mm] [Dd][Ee][Ll]) (%d+)$")}
if tonumber(sensspam[2]) < 40 then
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [40-99999]_', 1, 'md')
else 
           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ضع عدد من  *[40]* الى [_99999_]` 💯️', 1, 'md')
end
 else
database:set('bot:sens:spam'..msg.chat_id_,sensspam[2])
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Spam has been set to_ *'..sensspam[2]..'*', 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع الكليشه بالمسح للعدد` ✓⬅️ : *'..sensspam[2]..'*', 1, 'md')
end
end
end
          local text = msg.content_.text_:gsub('وضع كلايش بالتحذير','spam warn')
if text:match("^[Ss][Pp][Aa][Mm] [Ww][Aa][Rr][Nn] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
local sensspam = {string.match(text, "^([Ss][Pp][Aa][Mm] [Ww][Aa][Rr][Nn]) (%d+)$")}
if tonumber(sensspam[2]) < 40 then
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [40-99999]_', 1, 'md')
else 
           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ضع عدد من  *[40]* الى [_99999_]` 💯️', 1, 'md')
end
 else
database:set('bot:sens:spam:warn'..msg.chat_id_,sensspam[2])
                if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Spam Warn has been set to_ *'..sensspam[2]..'*', 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع الكليشه بالتحذير للعدد` ✓⬅️ : *'..sensspam[2]..'*', 1, 'md')
end
end
end

	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع زمن التكرار','flood time')
	if text:match("^[Ff][Ll][Oo][Oo][Dd] [Tt][Ii][Mm][Ee] (%d+)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local floodt = {string.match(text, "^([Ff][Ll][Oo][Oo][Dd] [Tt][Ii][Mm][Ee]) (%d+)$")} 
	if tonumber(floodt[2]) < 1 then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Wrong number*,_range is  [2-99999]_', 1, 'md')
       else 
           send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ضع عدد من  *[1]* الى [_99999_]` 💯️', 1, 'md')
end
	else
    database:set('flood:time:'..msg.chat_id_,floodt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Flood has been set to_ *'..floodt[2]..'*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع زمن التكرار للعدد ` ✓⬅️ : *'..floodt[2]..'*', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Ll][Ii][Nn][Kk]$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^وضع رابط$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         database:set("bot:group:link"..msg.chat_id_, 'Waiting For Link!\nPls Send Group Link')
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Please Send Group Link Now!*', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `قم بارسال الرابط ليتم حفظه` 📤', 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ll][Ii][Nn][Kk]$") or text:match("^الرابط$") then
	local link = database:get("bot:group:link"..msg.chat_id_)
	  if link then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '<b>Group link:</b>\n'..link, 1, 'html')
       else 
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  <code>رابط المجموعه ⬇️ :</code>\n'..link, 1, 'html')
end
	  else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*There is not link set yet. Please add one by #setlink .*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `لم يتم حفظ رابط ارسل [ وضع رابط ] لحفظ رابط جديد` 💯️', 1, 'md')
end
	  end
 	end
	
	if text:match("^[Ww][Ll][Cc] [Oo][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '#Done\nWelcome *Enabled* In This Supergroup.', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^[Ww][Ll][Cc] [Oo][Ff][Ff]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '#Done\nWelcome *Disabled* In This Supergroup.', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end
	
	if text:match("^تفعيل الترحيب$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تفعيل الترحيب ` ✔️', 1, 'md')
		 database:set("bot:welcome"..msg.chat_id_,true)
	end
	if text:match("^تعطيل الترحيب$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تعطيل الترحيب ` 💯️', 1, 'md')
		 database:del("bot:welcome"..msg.chat_id_)
	end

	if text:match("^[Ss][Ee][Tt] [Ww][Ll][Cc] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^([Ss][Ee][Tt] [Ww][Ll][Cc]) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Saved!*\nWlc Text:\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end
	
	if text:match("^وضع ترحيب (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local welcome = {string.match(text, "^(وضع ترحيب) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع الترحيب` ✓⬇️ :\n\n`'..welcome[2]..'`', 1, 'md')
		 database:set('welcome:'..msg.chat_id_,welcome[2])
	end

          local text = msg.content_.text_:gsub('حذف الترحيب','del wlc')
	if text:match("^[Dd][Ee][Ll] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Welcome Msg Has Been Deleted!*', 1, 'md')
       else 
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم حذف الترحيب` 💯️❌', 1, 'md')
end
		 database:del('welcome:'..msg.chat_id_)
	end
	
          local text = msg.content_.text_:gsub('جلب الترحيب','get wlc')
	if text:match("^[Gg][Ee][Tt] [Ww][Ll][Cc]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local wel = database:get('welcome:'..msg.chat_id_)
	if wel then
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الترحيب ` ⬇️ :'..wel, 1, 'md')
    else 
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, 'Welcome msg not saved!', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `لم يتم وضع ترحيب للمجموعه` 💯️', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('منع','bad')
	if text:match("^[Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local filters = {string.match(text, "^([Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(filters[2], 1, 50)
          database:hset('bot:filters:'..msg.chat_id_, name, 'filtered')
                if database:get('lang:gp:'..msg.chat_id_) then
		  send(msg.chat_id_, msg.id_, 1, "*New Word baded!*\n--> `"..name.."`", 1, 'md')
else 
  		  send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `"..name.."` `تم اضافتها لقائمه المنع` ✔️", 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('الغاء منع','unbad')
	if text:match("^[Uu][Nn][Bb][Aa][Dd] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local rws = {string.match(text, "^([Uu][Nn][Bb][Aa][Dd]) (.*)$")} 
    local name = string.sub(rws[2], 1, 50)
          database:hdel('bot:filters:'..msg.chat_id_, rws[2])
                if database:get('lang:gp:'..msg.chat_id_) then
		  send(msg.chat_id_, msg.id_, 1, "`"..rws[2].."` *Removed From baded List!*", 1, 'md')
else 
  		  send(msg.chat_id_, msg.id_, 1, " ✦┇ﮧ  "..rws[2].."` تم حذفها من قائمه المنع` ❌💯️", 1, 'md')
end
	end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('اذاعه','bc')
	if text:match("^bc (.*)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups") or 0
    local gpss = database:smembers("bot:groups") or 0
	local rws = {string.match(text, "^(bc) (.*)$")} 
	for i=1, #gpss do
		  send(gpss[i], 0, 1, rws[2], 1, 'html')
  end
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Done*\n_Your Msg Send to_ `'..gps..'` _Groups_', 1, 'md')
                   else
                     send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم نشر الرساله في` `'..gps..'` `مجموعه` ✔️', 1, 'md')
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Gg][Rr][Oo][Uu][Pp][Ss]$") and is_admin(msg.sender_user_id_, msg.chat_id_) or text:match("^الكروبات$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
    local gps = database:scard("bot:groups")
	local users = database:scard("bot:userss")
    local allmgs = database:get("bot:allmsgs")
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '*Groups :* `'..gps..'`', 1, 'md')
                 else
                   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `عدد الكروبات هي ⬅️ :` *'..gps..'*', 1, 'md')
end
	end
	
if  text:match("^[Mm][Ss][Gg]$") or text:match("^رسائلي$") and msg.reply_to_message_id_ == 0  then
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
       if not database:get('bot:id:mute'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "*Msgs : * `"..user_msgs.."`", 1, 'md')
      else 
        end
    else 
       if not database:get('bot:id:mute'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `عدد رسائلك هي ⬅️ :` *"..user_msgs.."*", 1, 'md')
      else 
        end
end
	end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^قفل (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local lockpt = {string.match(text, "^([Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKEPT = {string.match(text, "^(قفل) (.*)$")} 
    if lockpt[2] == "edit"and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "التعديل" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "_> Edit Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التعديل `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
                end
                database:set('editmsg'..msg.chat_id_,'delmsg')
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Lock edit is already_ *locked*', 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التعديل` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
                end
              end
            end
   if lockpt[2] == "bots" or TSHAKEPT[2] == "البوتات" then
              if not database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, "_> Bots Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل البوتات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
                end
                database:set('bot:bots:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Bots is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل البوتات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
                end
              end
            end
            	  if lockpt[2] == "flood ban" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "التكرار بالطرد" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood ban* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `قفل التكرار `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `☑️', 1, 'md')
                  end
                database:del('anti-flood:'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood ban* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التكرار` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
                end
              end
            end
            	  if lockpt[2] == "flood mute" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "التكرار بالكتم" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood mute* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `قفل التكرار `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الكتم》 `☑️', 1, 'md')
                  end
                database:del('anti-flood:warn'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood mute* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التكرار` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الكتم》` ☑️', 1, 'md')
                end
              end
          end
            	  if lockpt[2] == "flood del" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "التكرار بالمسح" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if database:get('anti-flood:del'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood del* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `قفل التكرار `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `☑️', 1, 'md')
                  end
                database:del('anti-flood:del'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood del* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التكرار` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
                end
              end
            end
        if lockpt[2] == "pin" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "التثبيت" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Pin Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التثبيت `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
                end
                database:set('bot:pin:mute'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                            send(msg.chat_id_, msg.id_, 1, "_> Pin is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التثبيت` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
                end
              end
            end
        if lockpt[2] == "pin warn" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEPT[2] == "التثبيت بالتحذير" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if not database:get('bot:pin:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                 send(msg.chat_id_, msg.id_, 1, "_> Pin warn Has been_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التثبيت `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
                end
                database:set('bot:pin:warn'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                            send(msg.chat_id_, msg.id_, 1, "_> Pin warn is Already_ *locked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التثبيت` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
                end
              end
            end
          end
          
	-----------------------------------------------------------------------------------------------
	
  	if text:match("^[Uu][Nn][Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^فتح (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unlockpt = {string.match(text, "^([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKEUN = {string.match(text, "^(فتح) (.*)$")} 
                if unlockpt[2] == "edit" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "التعديل" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('editmsg'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Edit Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التعديل `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
                end
                database:del('editmsg'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Lock edit is already_ *Unlocked*', 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التعديل` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "bots" or TSHAKEUN[2] == "البوتات" then
              if database:get('bot:bots:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Bots Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح البوتات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
                end
                database:del('bot:bots:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Bots is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح البوتات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
                end
              end
            end
            	  if unlockpt[2] == "flood ban" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "التكرار بالطرد" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood ban* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التكرار `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
                  end
                   database:set('anti-flood:'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood ban* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التكرار` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
                end
              end
            end
            	  if unlockpt[2] == "flood mute" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "التكرار بالكتم" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood mute* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التكرار `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الكتم》 `💯️', 1, 'md')
                  end
                   database:set('anti-flood:warn'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood mute* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التكرار` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الكتم》` 💯️', 1, 'md')
                end
              end
          end
            	  if unlockpt[2] == "flood del" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "التكرار بالمسح" and is_owner(msg.sender_user_id_, msg.chat_id_) then
                if not database:get('anti-flood:del'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                   send(msg.chat_id_, msg.id_, 1, '_> *Flood del* has been *unlocked*', 1, 'md')
                 else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التكرار `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
                  end
                   database:set('anti-flood:del'..msg.chat_id_,true)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> *Flood del* is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التكرار` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "pin" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "التثبيت" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('bot:pin:mute'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin Has been_ *Unlocked*", 1, 'md')
                else
                  send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التثبيت `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
                end
                database:del('bot:pin:mute'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التثبيت` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
                end
              end
            end
                if unlockpt[2] == "pin warn" and is_owner(msg.sender_user_id_, msg.chat_id_) or TSHAKEUN[2] == "التثبيت بالتحذير" and is_owner(msg.sender_user_id_, msg.chat_id_) then
              if database:get('bot:pin:warn'..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin warn Has been_ *Unlocked*", 1, 'md')
                else
                send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التثبيت `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
                end
                database:del('bot:pin:warn'..msg.chat_id_)
              else
                if database:get('lang:gp:'..msg.chat_id_) then
                    send(msg.chat_id_, msg.id_, 1, "_> Pin warn is Already_ *Unlocked*", 1, 'md')
                else
                 send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التثبيت` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
                end
              end
            end
              end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('قفل الكل بالثواني','lock all s')
  	if text:match("^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Ss] (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Ss] (%d+)$")}
	    		database:setex('bot:muteall'..msg.chat_id_, tonumber(mutept[1]), true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Group muted for_ *'..mutept[1]..'* _seconds!_', 1, 'md')
       else 
              send(msg.chat_id_, msg.id_, 1, "`✦┇ﮧ  تم قفل كل الوسائط لمدة` "..mutept[1].." `ثانيه` 🔐❌", 'md')
end
	end

          local text = msg.content_.text_:gsub('قفل الكل بالساعه','lock all h')
    if text:match("^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Hh]  (%d+)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local mutept = {string.match(text, "^[Ll][Oo][Cc][Kk] [Aa][Ll][Ll] [Hh] (%d+)$")}
        local hour = string.gsub(mutept[1], 'h', '')
        local num1 = tonumber(hour) * 3600
        local num = tonumber(num1)
            database:setex('bot:muteall'..msg.chat_id_, num, true)
                if database:get('lang:gp:'..msg.chat_id_) then
              send(msg.chat_id_, msg.id_, 1, "> Lock all has been enable for "..mutept[1].." hours !", 'md')
       else 
              send(msg.chat_id_, msg.id_, 1, "`✦┇ﮧ  تم قفل كل الوسائط لمدة` "..mutept[1].." `ساعه` 🔐❌", 'md')
end
     end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^قفل (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local mutept = {string.match(text, "^([Ll][Oo][Cc][Kk]) (.*)$")} 
	local TSHAKE = {string.match(text, "^(قفل) (.*)$")} 
      if mutept[2] == "all" or TSHAKE[2] == "الكل" then
	  if not database:get('bot:muteall'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل كل الوسائط `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:muteall'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> mute all is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل كل الوسائط` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "all warn" or TSHAKE[2] == "الكل بالتحذير" then
	  if not database:get('bot:muteallwarn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all warn has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل كل الوسائط `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:muteallwarn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل كل الوسائط` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "all ban" or TSHAKE[2] == "الكل بالطرد" then
	  if not database:get('bot:muteallban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل كل الوسائط `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:muteallban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل كل الوسائط` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "text" or TSHAKE[2] == "الدردشه" then
	  if not database:get('bot:text:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الدردشه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:text:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الدردشه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "text ban" or TSHAKE[2] == "الدردشه بالطرد" then
	  if not database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الدردشه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:text:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الدردشه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "text warn" or TSHAKE[2] == "الدردشه بالتحذير" then
	  if not database:get('bot:text:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الدردشه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:text:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الدردشه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline" or TSHAKE[2] == "الانلاين" then
	  if not database:get('bot:inline:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الانلاين `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:inline:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الانلاين` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline ban" or TSHAKE[2] == "الانلاين بالطرد" then
	  if not database:get('bot:inline:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الانلاين `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:inline:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الانلاين` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "inline warn" or TSHAKE[2] == "الانلاين بالتحذير" then
	  if not database:get('bot:inline:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الانلاين `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:inline:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الانلاين` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo" or TSHAKE[2] == "الصور" then
	  if not database:get('bot:photo:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الصور `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:photo:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الصور` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo ban" or TSHAKE[2] == "الصور بالطرد" then
	  if not database:get('bot:photo:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الصور `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:photo:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الصور` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "photo warn" or TSHAKE[2] == "الصور بالتحذير" then
	  if not database:get('bot:photo:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الصور `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:photo:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الصور` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "video" or TSHAKE[2] == "الفيديو" then
	  if not database:get('bot:video:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الفيديوهات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:video:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الفيديوهات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "video ban" or TSHAKE[2] == "الفيديو بالطرد" then
	  if not database:get('bot:video:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الفيديوهات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:video:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الفيديوهات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "video warn" or TSHAKE[2] == "الفيديو بالتحذير" then
	  if not database:get('bot:video:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الفيديوهات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:video:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الفيديوهات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif" or TSHAKE[2] == "المتحركه" then
	  if not database:get('bot:gifs:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المتحركه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:gifs:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المتحركه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif ban" or TSHAKE[2] == "المتحركه بالطرد" then
	  if not database:get('bot:gifs:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المتحركه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:gifs:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المتحركه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "gif warn" or TSHAKE[2] == "المتحركه بالتحذير" then
	  if not database:get('bot:gifs:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المتحركه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:gifs:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المتحركه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "music" or TSHAKE[2] == "الاغاني" then
	  if not database:get('bot:music:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الاغاني `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:music:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الاغاني` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "music ban" or TSHAKE[2] == "الاغاني بالطرد" then
	  if not database:get('bot:music:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الاغاني `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:music:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الاغاني` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "music warn" or TSHAKE[2] == "الاغاني بالتحذير" then
	  if not database:get('bot:music:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الاغاني `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:music:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الاغاني` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice" or TSHAKE[2] == "الصوت" then
	  if not database:get('bot:voice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الصوتيات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:voice:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الصوتيات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice ban" or TSHAKE[2] == "الصوت بالطرد" then
	  if not database:get('bot:voice:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الصوتيات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:voice:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الصوتيات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "voice warn" or TSHAKE[2] == "الصوت بالتحذير" then
	  if not database:get('bot:voice:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الصوتيات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:voice:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الصوتيات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "links" or TSHAKE[2] == "الروابط" then
	  if not database:get('bot:links:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الروابط `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:links:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الروابط` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "links ban" or TSHAKE[2] == "الروابط بالطرد" then
	  if not database:get('bot:links:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الروابط `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:links:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الروابط` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "links warn" or TSHAKE[2] == "الروابط بالتحذير" then
	  if not database:get('bot:links:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الروابط `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:links:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الروابط` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "location" or TSHAKE[2] == "الشبكات" then
	  if not database:get('bot:location:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الشبكات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:location:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الشبكات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "location ban" or TSHAKE[2] == "الشبكات بالطرد" then
	  if not database:get('bot:location:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الشبكات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:location:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الشبكات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "location warn" or TSHAKE[2] == "الشبكات بالتحذير" then
	  if not database:get('bot:location:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الشبكات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:location:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الشبكات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag" or TSHAKE[2] == "المعرف" then
	  if not database:get('bot:tag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المعرفات <@> `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:tag:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المعرفات <@>` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag ban" or TSHAKE[2] == "المعرف بالطرد" then
	  if not database:get('bot:tag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المعرفات <@> `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:tag:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المعرفات <@>` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "tag warn" or TSHAKE[2] == "المعرف بالتحذير" then
	  if not database:get('bot:tag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المعرفات <@> `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:tag:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المعرفات <@>` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag" or TSHAKE[2] == "التاك" then
	  if not database:get('bot:hashtag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التاكات <#> `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:hashtag:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التاكات <#>` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag ban" or TSHAKE[2] == "التاك بالطرد" then
	  if not database:get('bot:hashtag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التاكات <#> `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:hashtag:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التاكات <#>` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "hashtag warn" or TSHAKE[2] == "التاك بالتحذير" then
	  if not database:get('bot:hashtag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التاكات <#> `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:hashtag:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التاكات <#>` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact" or TSHAKE[2] == "الجهات" then
	  if not database:get('bot:contact:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل جهات الاتصال `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:contact:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل جهات الاتصال` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact ban" or TSHAKE[2] == "الجهات بالطرد" then
	  if not database:get('bot:contact:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل جهات الاتصال `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:contact:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل جهات الاتصال` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "contact warn" or TSHAKE[2] == "الجهات بالتحذير" then
	  if not database:get('bot:contact:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل جهات الاتصال `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:contact:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل جهات الاتصال` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage" or TSHAKE[2] == "المواقع" then
	  if not database:get('bot:webpage:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المواقع `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:webpage:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المواقع` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage ban" or TSHAKE[2] == "المواقع بالطرد" then
	  if not database:get('bot:webpage:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المواقع `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:webpage:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المواقع` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "webpage warn" or TSHAKE[2] == "المواقع بالتحذير" then
	  if not database:get('bot:webpage:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل المواقع `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:webpage:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل المواقع` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
    end
      if mutept[2] == "arabic" or TSHAKE[2] == "العربيه" then
	  if not database:get('bot:arabic:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل العربيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:arabic:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل العربيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "arabic ban" or TSHAKE[2] == "العربيه بالطرد" then
	  if not database:get('bot:arabic:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل العربيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:arabic:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل العربيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "arabic warn" or TSHAKE[2] == "العربيه بالتحذير" then
	  if not database:get('bot:arabic:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل العربيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:arabic:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل العربيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "english" or TSHAKE[2] == "الانكليزيه" then
	  if not database:get('bot:english:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الانكليزيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:english:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الانكليزيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "english ban" or TSHAKE[2] == "الانكليزيه بالطرد" then
	  if not database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الانكليزيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:english:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الانكليزيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "english warn" or TSHAKE[2] == "الانكليزيه بالتحذير" then
	  if not database:get('bot:english:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الانكليزيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:english:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الانكليزيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "spam del" or TSHAKE[2] == "الكلايش" then
	  if not database:get('bot:spam:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الكلايش `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:spam:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الكلايش` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "spam warn" or TSHAKE[2] == "الكلايش بالتحذير" then
	  if not database:get('bot:spam:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الكلايش `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:spam:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الكلايش` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker" or TSHAKE[2] == "الملصقات" then
	  if not database:get('bot:sticker:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الملصقات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:sticker:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الملصقات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker ban" or TSHAKE[2] == "الملصقات بالطرد" then
	  if not database:get('bot:sticker:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الملصقات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:sticker:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الملصقات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "sticker warn" or TSHAKE[2] == "الملصقات بالتحذير" then
	  if not database:get('bot:sticker:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الملصقات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:sticker:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الملصقات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
    end
      if mutept[2] == "file" or TSHAKE[2] == "الملفات" then
	  if not database:get('bot:document:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الملفات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:document:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الملفات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "file ban" or TSHAKE[2] == "الملفات بالطرد" then
	  if not database:get('bot:document:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الملفات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:document:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الملفات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "file warn" or TSHAKE[2] == "الملفات بالتحذير" then
	  if not database:get('bot:document:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الملفات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:document:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الملفات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
  end
  
      if mutept[2] == "markdown" or TSHAKE[2] == "الماركدون" then
	  if not database:get('bot:markdown:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الماركدون `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:markdown:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الماركدون` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "markdown ban" or TSHAKE[2] == "الماركدون بالطرد" then
	  if not database:get('bot:markdown:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الماركدون `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:markdown:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الماركدون` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "markdown warn" or TSHAKE[2] == "الماركدون بالتحذير" then
	  if not database:get('bot:markdown:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الماركدون `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:markdown:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الماركدون` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
    end
    
	  if mutept[2] == "service" or TSHAKE[2] == "الاشعارات" then
	  if not database:get('bot:tgservice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tgservice has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الاشعارات `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:tgservice:mute'..msg.chat_id_,true)
       else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tgservice is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الاشعارات` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd" or TSHAKE[2] == "التوجيه" then
	  if not database:get('bot:forward:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التوجيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:forward:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التوجيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd ban" or TSHAKE[2] == "التوجيه بالطرد" then
	  if not database:get('bot:forward:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التوجيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:forward:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التوجيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "fwd warn" or TSHAKE[2] == "التوجيه بالتحذير" then
	  if not database:get('bot:forward:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل التوجيه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:forward:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل التوجيه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd" or TSHAKE[2] == "الشارحه" then
	  if not database:get('bot:cmd:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الشارحه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
         database:set('bot:cmd:mute'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الشارحه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd ban" or TSHAKE[2] == "الشارحه بالطرد" then
	  if not database:get('bot:cmd:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الشارحه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
         database:set('bot:cmd:ban'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd ban is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الشارحه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` ☑️', 1, 'md')
      end
      end
      end
      if mutept[2] == "cmd warn" or TSHAKE[2] == "الشارحه بالتحذير" then
	  if not database:get('bot:cmd:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم` ✔️ `قفل الشارحه `🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
         database:set('bot:cmd:warn'..msg.chat_id_,true)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd warn is already_ *Locked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `قفل الشارحه` 🔐\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` ☑️', 1, 'md')
      end
      end
      end
	end 
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Uu][Nn][Ll][Oo][Cc][Kk] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^فتح (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local unmutept = {string.match(text, "^([Uu][Nn][Ll][Oo][Cc][Kk]) (.*)$")} 
	local UNTSHAKE = {string.match(text, "^(فتح) (.*)$")} 
      if unmutept[2] == "all" or UNTSHAKE[2] == "الكل" then
	  if database:get('bot:muteall'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح كل الوسائط `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:muteall'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> mute all is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح كــل الوسائط` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "all warn" or UNTSHAKE[2] == "الكل بالتحذير" then
	  if database:get('bot:muteallwarn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all warn has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح كل الوسائط `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:muteallwarn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح كل الوسائط` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "all ban" or UNTSHAKE[2] == "الكل بالطرد" then
	  if database:get('bot:muteallban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> mute all ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح كل الوسائط `🔓\n\n✦┇ﮧ  `خاصية : بالطرد `💯️', 1, 'md')
      end
         database:del('bot:muteallban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> mute all ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح كل الوسائط` 🔓\n\n✦┇ﮧ  `خاصية : بالطرد` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text" or UNTSHAKE[2] == "الدردشه" then
	  if database:get('bot:text:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الدردشه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:text:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الدردشه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text ban" or UNTSHAKE[2] == "الدردشه بالطرد" then
	  if database:get('bot:text:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الدردشه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:text:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الدردشه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "text warn" or UNTSHAKE[2] == "الدردشه بالتحذير" then
	  if database:get('bot:text:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> Text ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الدردشه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:text:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> Text warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الدردشه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline" or UNTSHAKE[2] == "الانلاين" then
	  if database:get('bot:inline:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الانلاين `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:inline:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الانلاين` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline ban" or UNTSHAKE[2] == "الانلاين بالطرد" then
	  if database:get('bot:inline:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الانلاين `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:inline:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الانلاين` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "inline warn" or UNTSHAKE[2] == "الانلاين بالتحذير" then
	  if database:get('bot:inline:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> inline ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الانلاين `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:inline:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> inline warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الانلاين` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo" or UNTSHAKE[2] == "الصور" then
	  if database:get('bot:photo:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الصور `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:photo:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الصور` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo ban" or UNTSHAKE[2] == "الصور بالطرد" then
	  if database:get('bot:photo:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الصور `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:photo:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الصور` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "photo warn" or UNTSHAKE[2] == "الصور بالتحذير" then
	  if database:get('bot:photo:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> photo ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الصور `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:photo:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> photo warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الصور` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video" or UNTSHAKE[2] == "الفيديو" then
	  if database:get('bot:video:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الفيديوهات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:video:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الفيديوهات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video ban" or UNTSHAKE[2] == "الفيديو بالطرد" then
	  if database:get('bot:video:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الفيديوهات `🔓\n\n✦┇ﮧ  `خاصية : بالطرد `💯️', 1, 'md')
      end
         database:del('bot:video:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الفيديوهات` 🔓\n\n✦┇ﮧ  `خاصية : بالطرد` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "video warn" or UNTSHAKE[2] == "الفيديو بالتحذير" then
	  if database:get('bot:video:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> video ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الفيديوهات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:video:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> video warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الفيديوهات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif" or UNTSHAKE[2] == "المتحركه" then
	  if database:get('bot:gifs:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المتحركه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:gifs:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المتحركه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif ban" or UNTSHAKE[2] == "المتحركه بالطرد" then
	  if database:get('bot:gifs:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المتحركه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:gifs:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المتحركه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "gif warn" or UNTSHAKE[2] == "المتحركه بالتحذير" then
	  if database:get('bot:gifs:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> gifs ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المتحركه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:gifs:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> gifs warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المتحركه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music" or UNTSHAKE[2] == "الاغاني" then
	  if database:get('bot:music:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الاغاني `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:music:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الاغاني` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music ban" or UNTSHAKE[2] == "الاغاني بالطرد" then
	  if database:get('bot:music:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الاغاني `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:music:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الاغاني` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "music warn" or UNTSHAKE[2] == "الاغاني بالتحذير" then
	  if database:get('bot:music:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> music ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الاغاني `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:music:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> music warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الاغاني` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice" or UNTSHAKE[2] == "الصوت" then
	  if database:get('bot:voice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الصوتيات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:voice:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الصوتيات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice ban" or UNTSHAKE[2] == "الصوت بالطرد" then
	  if database:get('bot:voice:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الصوتيات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:voice:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الصوتيات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "voice warn" or UNTSHAKE[2] == "الصوت بالتحذير" then
	  if database:get('bot:voice:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> voice ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الصوتيات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:voice:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> voice warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الصوتيات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links" or UNTSHAKE[2] == "الروابط" then
	  if database:get('bot:links:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الروابط `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:links:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الروابط` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links ban" or UNTSHAKE[2] == "الروابط بالطرد" then
	  if database:get('bot:links:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الروابط `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:links:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الروابط` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "links warn" or UNTSHAKE[2] == "الروابط بالتحذير" then
	  if database:get('bot:links:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> links ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الروابط `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:links:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> links warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الروابط` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location" or UNTSHAKE[2] == "الشبكات" then
	  if database:get('bot:location:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الشبكات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:location:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الشبكات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location ban" or UNTSHAKE[2] == "الشبكات بالطرد" then
	  if database:get('bot:location:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الشبكات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:location:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الشبكات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "location warn" or UNTSHAKE[2] == "الشبكات بالتحذير" then
	  if database:get('bot:location:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> location ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الشبكات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:location:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> location warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الشبكات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end 
      end
      if unmutept[2] == "tag" or UNTSHAKE[2] == "المعرف" then
	  if database:get('bot:tag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المعرفات <@> `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:tag:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المعرفات <@>` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "tag ban" or UNTSHAKE[2] == "المعرف بالطرد" then
	  if database:get('bot:tag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المعرفات <@> `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:tag:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المعرفات <@>` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "tag warn" or UNTSHAKE[2] == "المعرف بالتحذير" then
	  if database:get('bot:tag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المعرفات <@> `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:tag:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tag warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المعرفات <@>` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag" or UNTSHAKE[2] == "التاك" then
	  if database:get('bot:hashtag:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التاكات <#> `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:hashtag:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التاكات <#>` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag ban" or UNTSHAKE[2] == "التاك بالطرد" then
	  if database:get('bot:hashtag:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التاكات <#> `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:hashtag:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التاكات <#>` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "hashtag warn" or UNTSHAKE[2] == "التاك بالتحذير" then
	  if database:get('bot:hashtag:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> hashtag ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التاكات <#> `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:hashtag:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> hashtag warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التاكات <#>` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact" or UNTSHAKE[2] == "الجهات" then
	  if database:get('bot:contact:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح جهات الاتصال `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:contact:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح جهات الاتصال` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact ban" or UNTSHAKE[2] == "الجهات بالطرد" then
	  if database:get('bot:contact:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح جهات الاتصال `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:contact:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح جهات الاتصال` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "contact warn" or UNTSHAKE[2] == "الجهات بالتحذير" then
	  if database:get('bot:contact:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> contact ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح جهات الاتصال `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:contact:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> contact warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح جهات الاتصال` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage" or UNTSHAKE[2] == "المواقع" then
	  if database:get('bot:webpage:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المواقع `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:webpage:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المواقع` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage ban" or UNTSHAKE[2] == "المواقع بالطرد" then
	  if database:get('bot:webpage:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المواقع `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:webpage:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المواقع` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "webpage warn" or UNTSHAKE[2] == "المواقع بالتحذير" then
	  if database:get('bot:webpage:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> webpage ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح المواقع `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:webpage:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> webpage warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح المواقع` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
    end
      if unmutept[2] == "arabic" or UNTSHAKE[2] == "العربيه" then
	  if database:get('bot:arabic:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح العربيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:arabic:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح العربيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "arabic ban" or UNTSHAKE[2] == "العربيه بالطرد" then
	  if database:get('bot:arabic:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح العربيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:arabic:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح العربيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "arabic warn" or UNTSHAKE[2] == "العربيه بالتحذير" then
	  if database:get('bot:arabic:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> arabic ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح العربيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:arabic:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> arabic warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح العربيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english" or UNTSHAKE[2] == "الانكليزيه" then
	  if database:get('bot:english:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الانكليزيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:english:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الانكليزيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english ban" or UNTSHAKE[2] == "الانكليزيه بالطرد" then
	  if database:get('bot:english:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الانكليزيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:english:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الانكليزيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "english warn" or UNTSHAKE[2] == "الانكليزيه بالتحذير" then
	  if database:get('bot:english:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> english ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الانكليزيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:english:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> english warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الانكليزيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "spam del" or UNTSHAKE[2] == "الكلايش" then
	  if database:get('bot:spam:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الكلايش `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:spam:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الكلايش` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "spam warn" or UNTSHAKE[2] == "الكلايش بالتحذير" then
	  if database:get('bot:spam:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> spam ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الكلايش `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:spam:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> spam warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الكلايش` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker" or UNTSHAKE[2] == "الملصقات" then
	  if database:get('bot:sticker:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الملصقات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:sticker:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الملصقات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker ban" or UNTSHAKE[2] == "الملصقات بالطرد" then
	  if database:get('bot:sticker:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الملصقات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:sticker:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الملصقات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "sticker warn" or UNTSHAKE[2] == "الملصقات بالتحذير" then
	  if database:get('bot:sticker:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> sticker ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الملصقات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:sticker:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> sticker warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الملصقات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
    end

      if unmutept[2] == "file" or UNTSHAKE[2] == "الملفات" then
	  if database:get('bot:document:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الملفات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:document:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الملفات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "file ban" or UNTSHAKE[2] == "الملفات بالطرد" then
	  if database:get('bot:document:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الملفات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:document:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الملفات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "file warn" or UNTSHAKE[2] == "الملفات بالتحذير" then
	  if database:get('bot:document:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> file ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الملفات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:document:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> file warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الملفات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end    

      if unmutept[2] == "markdown" or UNTSHAKE[2] == "الماركدون" then
	  if database:get('bot:markdown:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الماركدون `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:markdown:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الماركدون` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "markdown ban" or UNTSHAKE[2] == "الماركدون بالطرد" then
	  if database:get('bot:markdown:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الماركدون `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:markdown:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الماركدون` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "markdown warn" or UNTSHAKE[2] == "الماركدون بالتحذير" then
	  if database:get('bot:markdown:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> markdown ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الماركدون `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:markdown:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> markdown warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الماركدون` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end    


	  if unmutept[2] == "service" or UNTSHAKE[2] == "الاشعارات" then
	  if database:get('bot:tgservice:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> tgservice has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الاشعارات `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:tgservice:mute'..msg.chat_id_)
       else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> tgservice is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الاشعارات` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd" or UNTSHAKE[2] == "التوجيه" then
	  if database:get('bot:forward:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التوجيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:forward:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التوجيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd ban" or UNTSHAKE[2] == "التوجيه بالطرد" then
	  if database:get('bot:forward:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التوجيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:forward:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التوجيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "fwd warn" or UNTSHAKE[2] == "التوجيه بالتحذير" then
	  if database:get('bot:forward:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> forward ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح التوجيه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:forward:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> forward warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح التوجيه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd" or UNTSHAKE[2] == "الشارحه" then
	  if database:get('bot:cmd:mute'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الشارحه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》 `💯️', 1, 'md')
      end
         database:del('bot:cmd:mute'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الشارحه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《المسح》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd ban" or UNTSHAKE[2] == "الشارحه بالطرد" then
	  if database:get('bot:cmd:ban'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الشارحه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》 `💯️', 1, 'md')
      end
         database:del('bot:cmd:ban'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd ban is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الشارحه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《الطرد》` 💯️', 1, 'md')
      end
      end
      end
      if unmutept[2] == "cmd warn" or UNTSHAKE[2] == "الشارحه بالتحذير" then
	  if database:get('bot:cmd:warn'..msg.chat_id_) then
    if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_> cmd ban has been_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم `✔️ `فتح الشارحه `🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》 `💯️', 1, 'md')
      end
         database:del('bot:cmd:warn'..msg.chat_id_)
      else
    if database:get('lang:gp:'..msg.chat_id_) then
                  send(msg.chat_id_, msg.id_, 1, '_> cmd warn is already_ *unLocked*', 1, 'md')
      else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم` ✔️ `فتح الشارحه` 🔓\n\n✦┇ﮧ  `مستوى الحمايه《التحذير》` 💯️', 1, 'md')
      end
      end
      end
	end 
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تعديل','edit')
  	if text:match("^[Ee][Dd][Ii][Tt] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local editmsg = {string.match(text, "^([Ee][Dd][Ii][Tt]) (.*)$")} 
		 edit(msg.chat_id_, msg.reply_to_message_id_, nil, editmsg[2], 1, 'html')
    if database:get('lang:gp:'..msg.chat_id_) then
		 	          send(msg.chat_id_, msg.id_, 1, '*Done* _Edit My Msg_', 1, 'md')
else 
		 	          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تعديل الرساله` ✔️📌', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
    if text:match("^[Cc][Ll][Ee][Aa][Nn] [Gg][Bb][Aa][Nn][Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^مسح قائمه العام$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    if database:get('lang:gp:'..msg.chat_id_) then
      text = '_> Banall has been_ *Cleaned*'
    else 
      text = '✦┇ﮧ  `تم مسح قائمه العام` ❌💯️'
end
      database:del('bot:gbanned:')
	    send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
  end

    if text:match("^[Cc][Ll][Ee][Aa][Nn] [Aa][Dd][Mm][Ii][Nn][Ss]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) or text:match("^مسح ادمنيه البوت$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
    if database:get('lang:gp:'..msg.chat_id_) then
      text = '_> adminlist has been_ *Cleaned*'
    else 
      text = '✦┇ﮧ  `تم مسح قائمه ادمنيه البوت` ❌💯️'
end
      database:del('bot:admins:')
	    send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
  end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('مسح','clean')
  	if text:match("^[Cc][Ll][Ee][Aa][Nn] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Cc][Ll][Ee][Aa][Nn]) (.*)$")} 
       if txt[2] == 'banlist' or txt[2] == 'Banlist' or txt[2] == 'المحظورين' then
	      database:del('bot:banned:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Banlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم مسح قائمه المحظورين` ❌💯️', 1, 'md')
end
       end
	   if txt[2] == 'bots' or txt[2] == 'Bots' or txt[2] == 'البوتات' then
	  local function g_bots(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          chat_kick(msg.chat_id_,bots[i].msg.sender_user_id_)
          end 
      end
    channel_get_bots(msg.chat_id_,g_bots) 
    if database:get('lang:gp:'..msg.chat_id_) then
	          send(msg.chat_id_, msg.id_, 1, '_> All bots_ *kicked!*', 1, 'md')
          else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم طرد جميع البوتات` ❌💯️', 1, 'md')
end
	end
	   if txt[2] == 'modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Modlist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'الادمنيه' and is_owner(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:mods:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Modlist has been_ *Cleaned*', 1, 'md')
      else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم مسح قائمه الادمنيه` ❌💯️', 1, 'md')
end
     end 
	   if txt[2] == 'viplist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'Viplist' and is_owner(msg.sender_user_id_, msg.chat_id_) or txt[2] == 'الاعضاء المميزين' and is_owner(msg.sender_user_id_, msg.chat_id_) then
	      database:del('bot:vipgp:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> Viplist has been_ *Cleaned*', 1, 'md')
      else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم مسح قائمه الاعضاء المميزين` ❌💯️', 1, 'md')
end
       end 
	   if txt[2] == 'owners' and is_sudo(msg) or txt[2] == 'Owners' and is_sudo(msg) or txt[2] == 'المدراء' and is_sudo(msg) then
	      database:del('bot:owners:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> ownerlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم مسح قائمه المدراء` ❌💯️', 1, 'md')
end
       end
	   if txt[2] == 'rules' or txt[2] == 'Rules' or txt[2] == 'القوانين' then
	      database:del('bot:rules'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> rules has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم مسح القوانين المحفوظه` ❌💯️', 1, 'md')
end
       end
	   if txt[2] == 'link' or  txt[2] == 'Link' or  txt[2] == 'الرابط' then
	      database:del('bot:group:link'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> link has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم مسح الرابط المحفوظ` ❌💯️', 1, 'md')
end
       end
	   if txt[2] == 'badlist' or txt[2] == 'Badlist' or txt[2] == 'قائمه المنع' then
	      database:del('bot:filters:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> badlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم مسح قائمه المنع` ❌💯️', 1, 'md')
end
       end
	   if txt[2] == 'silentlist' or txt[2] == 'Silentlist' or txt[2] == 'المكتومين' then
	      database:del('bot:muted:'..msg.chat_id_)
    if database:get('lang:gp:'..msg.chat_id_) then
          send(msg.chat_id_, msg.id_, 1, '_> silentlist has been_ *Cleaned*', 1, 'md')
        else 
          send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم مسح قائمه المكتومين` ❌💯️', 1, 'md')
end
       end
       
    end 
	-----------------------------------------------------------------------------------------------
  	 if text:match("^[Ss] [Dd][Ee][Ll]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`lock | 🔐`'
	else
	mute_all = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`lock | 🔐`'
	else
	mute_text = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`lock | 🔐`'
	else
	mute_photo = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`lock | 🔐`'
	else
	mute_video = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`lock | 🔐`'
	else
	mute_gifs = '`unlock | 🔓`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`unlock | 🔓`'
	else  
	mute_flood = '`lock | 🔐`'
	end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 10
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 1
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`lock | 🔐`'
	else
	mute_music = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`lock | 🔐`'
	else
	mute_bots = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`lock | 🔐`'
	else
	mute_in = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`lock | 🔐`'
	else
	mute_voice = '`unlock | 🔓`'
end

	if database:get('bot:document:mute'..msg.chat_id_) then
	mute_doc = '`lock | 🔐`'
	else
	mute_doc = '`unlock | 🔓`'
end

	if database:get('bot:markdown:mute'..msg.chat_id_) then
	mute_mdd = '`lock | 🔐`'
	else
	mute_mdd = '`unlock | 🔓`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`lock | 🔐`'
	else
	mute_edit = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`lock | 🔐`'
	else
	mute_links = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`lock | 🔐`'
	else
	lock_pin = '`unlock | 🔓`'
	end 
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`lock | 🔐`'
	else
	lock_sticker = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`lock | 🔐`'
	else
	lock_tgservice = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`lock | 🔐`'
	else
	lock_wp = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`lock | 🔐`'
	else
	lock_htag = '`unlock | 🔓`'
end

   if database:get('bot:cmd:mute'..msg.chat_id_) then
	lock_cmd = '`lock | 🔐`'
	else
	lock_cmd = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`lock | 🔐`'
	else
	lock_tag = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`lock | 🔐`'
	else
	lock_location = '`unlock | 🔓`'
end
  ------------
if not database:get('bot:sens:spam'..msg.chat_id_) then
spam_c = 300
else
spam_c = database:get('bot:sens:spam'..msg.chat_id_)
end

if not database:get('bot:sens:spam:warn'..msg.chat_id_) then
spam_d = 300
else
spam_d = database:get('bot:sens:spam:warn'..msg.chat_id_)
end

	------------
  if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`lock | 🔐`'
	else
	lock_contact = '`unlock | 🔓`'
	end
	------------
  if database:get('bot:spam:mute'..msg.chat_id_) then
	mute_spam = '`lock | 🔐`'
	else
	mute_spam = '`unlock | 🔓`'
end

	if database:get('anti-flood:warn'..msg.chat_id_) then
	lock_flood = '`unlock | 🔓`'
	else 
	lock_flood = '`lock | 🔐`'
end

	if database:get('anti-flood:del'..msg.chat_id_) then
	del_flood = '`unlock | 🔓`'
	else 
	del_flood = '`lock | 🔐`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`lock | 🔐`'
	else
	lock_english = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`lock | 🔐`'
	else
	lock_arabic = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`lock | 🔐`'
	else
	lock_forward = '`unlock | 🔓`'
end

    if database:get('bot:rep:mute'..msg.chat_id_) then
	lock_rep = '`lock | 🔐`'
	else
	lock_rep = '`unlock | 🔓`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '`active | ✔`'
	else
	send_welcome = '`inactive | ⭕`'
end
		if not database:get('flood:max:warn'..msg.chat_id_) then
	flood_warn = 10
	else
	flood_warn = database:get('flood:max:warn'..msg.chat_id_)
end
		if not database:get('flood:max:del'..msg.chat_id_) then
	flood_del = 10
	else
	flood_del = database:get('flood:max:del'..msg.chat_id_)
end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Del*\n======================\n*Del all* : "..mute_all.."\n" .."*Del Links* : "..mute_links.."\n" .."*Del Edit* : "..mute_edit.."\n" .."*Del Bots* : "..mute_bots.."\n" .."*Del Inline* : "..mute_in.."\n" .."*Del English* : "..lock_english.."\n" .."*Del Forward* : "..lock_forward.."\n" .."*Del Pin* : "..lock_pin.."\n" .."*Del Arabic* : "..lock_arabic.."\n" .."*Del Hashtag* : "..lock_htag.."\n".."*Del tag* : "..lock_tag.."\n" .."*Del Webpage* : "..lock_wp.."\n" .."*Del Location* : "..lock_location.."\n" .."*Del Tgservice* : "..lock_tgservice.."\n"
.."*Del Spam* : "..mute_spam.."\n" .."*Del Photo* : "..mute_photo.."\n" .."*Del Text* : "..mute_text.."\n" .."*Del Gifs* : "..mute_gifs.."\n" .."*Del Voice* : "..mute_voice.."\n" .."*Del Music* : "..mute_music.."\n" .."*Del Video* : "..mute_video.."\n*Del Cmd* : "..lock_cmd.."\n" .."*Del Markdown* : "..mute_mdd.."\n*Del Document* : "..mute_doc.."\n" .."*Flood Ban* : "..mute_flood.."\n" .."*Flood Mute* : "..lock_flood.."\n" .."*Flood del* : "..del_flood.."\n" .."*Setting reply* : "..lock_rep.."\n"
.."======================\n*Welcome* : "..send_welcome.."\n*Flood Time*  "..flood_t.."\n" .."*Flood Max* : "..flood_m.."\n" .."*Flood Mute* : "..flood_warn.."\n" .."*Flood del* : "..flood_del.."\n" .."*Number Spam* : "..spam_c.."\n" .."*Warn Spam* : "..spam_d.."\n"
 .."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end

          local text = msg.content_.text_:gsub('اعدادات المسح','sdd1')
  	 if text:match("^[Ss][Dd][Dd]1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteall'..msg.chat_id_) then
	mute_all = '`مفعل | 🔐`'
	else
	mute_all = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:text:mute'..msg.chat_id_) then
	mute_text = '`مفعل | 🔐`'
	else
	mute_text = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:photo:mute'..msg.chat_id_) then
	mute_photo = '`مفعل | 🔐`'
	else
	mute_photo = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:video:mute'..msg.chat_id_) then
	mute_video = '`مفعل | 🔐`'
	else
	mute_video = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:gifs:mute'..msg.chat_id_) then
	mute_gifs = '`مفعل | 🔐`'
	else
	mute_gifs = '`معطل | 🔓`'
	end
	------------
	if database:get('anti-flood:'..msg.chat_id_) then
	mute_flood = '`معطل | 🔓`'
	else  
	mute_flood = '`مفعل | 🔐`'
end
	------------
	if not database:get('flood:max:'..msg.chat_id_) then
	flood_m = 10
	else
	flood_m = database:get('flood:max:'..msg.chat_id_)
end
	------------
	if not database:get('flood:time:'..msg.chat_id_) then
	flood_t = 1
	else
	flood_t = database:get('flood:time:'..msg.chat_id_)
	end
	------------
	if database:get('bot:music:mute'..msg.chat_id_) then
	mute_music = '`مفعل | 🔐`'
	else
	mute_music = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:bots:mute'..msg.chat_id_) then
	mute_bots = '`مفعل | 🔐`'
	else
	mute_bots = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:inline:mute'..msg.chat_id_) then
	mute_in = '`مفعل | 🔐`'
	else
	mute_in = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:voice:mute'..msg.chat_id_) then
	mute_voice = '`مفعل | 🔐`'
	else
	mute_voice = '`معطل | 🔓`'
	end
	------------
	if database:get('editmsg'..msg.chat_id_) then
	mute_edit = '`مفعل | 🔐`'
	else
	mute_edit = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:links:mute'..msg.chat_id_) then
	mute_links = '`مفعل | 🔐`'
	else
	mute_links = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:pin:mute'..msg.chat_id_) then
	lock_pin = '`مفعل | 🔐`'
	else
	lock_pin = '`معطل | 🔓`'
end 

	if database:get('bot:document:mute'..msg.chat_id_) then
	mute_doc = '`مفعل | 🔐`'
	else
	mute_doc = '`معطل | 🔓`'
end

	if database:get('bot:markdown:mute'..msg.chat_id_) then
	mute_mdd = '`مفعل | 🔐`'
	else
	mute_mdd = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:sticker:mute'..msg.chat_id_) then
	lock_sticker = '`مفعل | 🔐`'
	else
	lock_sticker = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:tgservice:mute'..msg.chat_id_) then
	lock_tgservice = '`مفعل | 🔐`'
	else
	lock_tgservice = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:webpage:mute'..msg.chat_id_) then
	lock_wp = '`مفعل | 🔐`'
	else
	lock_wp = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:hashtag:mute'..msg.chat_id_) then
	lock_htag = '`مفعل | 🔐`'
	else
	lock_htag = '`معطل | 🔓`'
end

   if database:get('bot:cmd:mute'..msg.chat_id_) then
	lock_cmd = '`مفعل | 🔐`'
	else
	lock_cmd = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:tag:mute'..msg.chat_id_) then
	lock_tag = '`مفعل | 🔐`'
	else
	lock_tag = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:location:mute'..msg.chat_id_) then
	lock_location = '`مفعل | 🔐`'
	else
	lock_location = '`معطل | 🔓`'
end
  ------------
if not database:get('bot:sens:spam'..msg.chat_id_) then
spam_c = 300
else
spam_c = database:get('bot:sens:spam'..msg.chat_id_)
end

if not database:get('bot:sens:spam:warn'..msg.chat_id_) then
spam_d = 300
else
spam_d = database:get('bot:sens:spam:warn'..msg.chat_id_)
end
	------------
  if database:get('bot:contact:mute'..msg.chat_id_) then
	lock_contact = '`مفعل | 🔐`'
	else
	lock_contact = '`معطل | 🔓`'
	end
	------------
  if database:get('bot:spam:mute'..msg.chat_id_) then
	mute_spam = '`مفعل | 🔐`'
	else
	mute_spam = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:english:mute'..msg.chat_id_) then
	lock_english = '`مفعل | 🔐`'
	else
	lock_english = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:arabic:mute'..msg.chat_id_) then
	lock_arabic = '`مفعل | 🔐`'
	else
	lock_arabic = '`معطل | 🔓`'
end

	if database:get('anti-flood:warn'..msg.chat_id_) then
	lock_flood = '`معطل | 🔓`'
	else 
	lock_flood = '`مفعل | 🔐`'
end

	if database:get('anti-flood:del'..msg.chat_id_) then
	del_flood = '`معطل | 🔓`'
	else 
	del_flood = '`مفعل | 🔐`'
	end
	------------
    if database:get('bot:forward:mute'..msg.chat_id_) then
	lock_forward = '`مفعل | 🔐`'
	else
	lock_forward = '`معطل | 🔓`'
end

    if database:get('bot:rep:mute'..msg.chat_id_) then
	lock_rep = '`معطله | 🔐`'
	else
	lock_rep = '`مفعله | 🔓`'
	end

    if database:get('bot:repsudo:mute'..msg.chat_id_) then
	lock_repsudo = '`معطله | 🔐`'
	else
	lock_repsudo = '`مفعله | 🔓`'
	end
	
    if database:get('bot:repowner:mute'..msg.chat_id_) then
	lock_repowner = '`معطله | 🔐`'
	else
	lock_repowner = '`مفعله | 🔓`'
	end

    if database:get('bot:id:mute'..msg.chat_id_) then
	lock_id = '`معطل | 🔐`'
	else
	lock_id = '`مفعل | 🔓`'
	end
	------------
	if database:get("bot:welcome"..msg.chat_id_) then
	send_welcome = '`مفعل | ✔`'
	else
	send_welcome = '`معطل | ⭕`'
end
		if not database:get('flood:max:warn'..msg.chat_id_) then
	flood_warn = 10
	else
	flood_warn = database:get('flood:max:warn'..msg.chat_id_)
end
	if not database:get('flood:max:del'..msg.chat_id_) then
	flood_del = 10
	else
	flood_del = database:get('flood:max:del'..msg.chat_id_)
end
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`لا نهائي`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "✦┇ﮧ  `اعدادات المجموعه بالمسح`\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  `كل الوسائط` : "..mute_all.."\n"
	 .."✦┇ﮧ  `الروابط` : "..mute_links.."\n"
	 .."✦┇ﮧ  `التعديل` : "..mute_edit.."\n" 
	 .."✦┇ﮧ  `البوتات` : "..mute_bots.."\n"
	 .."✦┇ﮧ  `اللغه الانكليزيه` : "..lock_english.."\n"
	 .."✦┇ﮧ  `اعاده التوجيه` : "..lock_forward.."\n" 
	 .."✦┇ﮧ  `المواقع` : "..lock_wp.."\n" 
	 .."✦┇ﮧ  `التثبيت` : "..lock_pin.."\n" 
	 .."✦┇ﮧ  `اللغه العربيه` : "..lock_arabic.."\n\n"
	 .."✦┇ﮧ  `التاكات` : "..lock_htag.."\n"
	 .."✦┇ﮧ  `المعرفات` : "..lock_tag.."\n" 
	 .."✦┇ﮧ  `الشبكات` : "..lock_location.."\n" 
	 .."✦┇ﮧ  `الاشعارات` : "..lock_tgservice.."\n"
   .."✦┇ﮧ  `الكلايش` : "..mute_spam.."\n"
   .."✦┇ﮧ  `التكرار بالطرد` : "..mute_flood.."\n" 
   .."✦┇ﮧ  `التكرار بالكتم` : "..lock_flood.."\n" 
   .."✦┇ﮧ  `التكرار بالمسح` : "..del_flood.."\n" 
   .."✦┇ﮧ  `الدردشه` : "..mute_text.."\n"
   .."✦┇ﮧ  `الصور المتحركه` : "..mute_gifs.."\n\n"
   .."✦┇ﮧ  `الصوتيات` : "..mute_voice.."\n" 
   .."✦┇ﮧ  `الاغاني` : "..mute_music.."\n"
	 .."✦┇ﮧ  `الانلاين` : "..mute_in.."\n" 
   .."✦┇ﮧ  `الملصقات` : "..lock_sticker.."\n"
	 .."✦┇ﮧ  `جهات الاتصال` : "..lock_contact.."\n" 
   .."✦┇ﮧ  `الفيديوهات` : "..mute_video.."\n✦┇ﮧ  `الشارحه` : "..lock_cmd.."\n"
   .."✦┇ﮧ  `الماركدون` : "..mute_mdd.."\n✦┇ﮧ  `الملفات` : "..mute_doc.."\n" 
   .."✦┇ﮧ  `الصور` : "..mute_photo.."\n"
   .."✦┇ﮧ  `ردود البوت` : "..lock_rep.."\n"
   .."✦┇ﮧ  `ردود المطور` : "..lock_repsudo.."\n"
   .."✦┇ﮧ  `ردود المدير` : "..lock_repowner.."\n"
   .."✦┇ﮧ  `الايدي` : "..lock_id.."\n\n"
   .."||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  `الترحيب` : "..send_welcome.."\n✦┇ﮧ  `زمن التكرار` : "..flood_t.."\n"
   .."✦┇ﮧ  `عدد التكرار بالطرد` : "..flood_m.."\n"
   .."✦┇ﮧ  `عدد التكرار بالكتم` : "..flood_warn.."\n\n"
   .."✦┇ﮧ  `عدد التكرار بالمسح` : "..flood_del.."\n"
   .."✦┇ﮧ  `عدد الكلايش بالمسح` : "..spam_c.."\n"
   .."✦┇ﮧ  `عدد الكلايش بالتحذير` : "..spam_d.."\n"
   .."✦┇ﮧ  `انقضاء البوت` : "..exp_dat.." `يوم`\n||ـ••••••••••••••••••••••••••••••••••••ـ||"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
  	 if text:match("^[Ss] [Ww][Aa][Rr][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallwarn'..msg.chat_id_) then
	mute_all = '`lock | 🔐`'
	else
	mute_all = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:text:warn'..msg.chat_id_) then
	mute_text = '`lock | 🔐`'
	else
	mute_text = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:photo:warn'..msg.chat_id_) then
	mute_photo = '`lock | 🔐`'
	else
	mute_photo = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:video:warn'..msg.chat_id_) then
	mute_video = '`lock | 🔐`'
	else
	mute_video = '`unlock | 🔓`'
end

	if database:get('bot:spam:warn'..msg.chat_id_) then
	mute_spam = '`lock | 🔐`'
	else
	mute_spam = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:gifs:warn'..msg.chat_id_) then
	mute_gifs = '`lock | 🔐`'
	else
	mute_gifs = '`unlock | 🔓`'
end

	------------
	if database:get('bot:music:warn'..msg.chat_id_) then
	mute_music = '`lock | 🔐`'
	else
	mute_music = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:inline:warn'..msg.chat_id_) then
	mute_in = '`lock | 🔐`'
	else
	mute_in = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:voice:warn'..msg.chat_id_) then
	mute_voice = '`lock | 🔐`'
	else
	mute_voice = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:links:warn'..msg.chat_id_) then
	mute_links = '`lock | 🔐`'
	else
	mute_links = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:sticker:warn'..msg.chat_id_) then
	lock_sticker = '`lock | 🔐`'
	else
	lock_sticker = '`unlock | 🔓`'
	end
	------------
   if database:get('bot:cmd:warn'..msg.chat_id_) then
	lock_cmd = '`lock | 🔐`'
	else
	lock_cmd = '`unlock | 🔓`'
end

    if database:get('bot:webpage:warn'..msg.chat_id_) then
	lock_wp = '`lock | 🔐`'
	else
	lock_wp = '`unlock | 🔓`'
end

	if database:get('bot:document:warn'..msg.chat_id_) then
	mute_doc = '`lock | 🔐`'
	else
	mute_doc = '`unlock | 🔓`'
end

	if database:get('bot:markdown:warn'..msg.chat_id_) then
	mute_mdd = '`lock | 🔐`'
	else
	mute_mdd = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:hashtag:warn'..msg.chat_id_) then
	lock_htag = '`lock | 🔐`'
	else
	lock_htag = '`unlock | 🔓`'
end
	if database:get('bot:pin:warn'..msg.chat_id_) then
	lock_pin = '`lock | 🔐`'
	else
	lock_pin = '`unlock | 🔓`'
	end 
	------------
    if database:get('bot:tag:warn'..msg.chat_id_) then
	lock_tag = '`lock | 🔐`'
	else
	lock_tag = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:location:warn'..msg.chat_id_) then
	lock_location = '`lock | 🔐`'
	else
	lock_location = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:contact:warn'..msg.chat_id_) then
	lock_contact = '`lock | 🔐`'
	else
	lock_contact = '`unlock | 🔓`'
	end
	------------
	
    if database:get('bot:english:warn'..msg.chat_id_) then
	lock_english = '`lock | 🔐`'
	else
	lock_english = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:arabic:warn'..msg.chat_id_) then
	lock_arabic = '`lock | 🔐`'
	else
	lock_arabic = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:forward:warn'..msg.chat_id_) then
	lock_forward = '`lock | 🔐`'
	else
	lock_forward = '`unlock | 🔓`'
end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Warn*\n======================\n*Warn all* : "..mute_all.."\n" .."*Warn Links* : "..mute_links.."\n" .."*Warn Inline* : "..mute_in.."\n" .."*Warn Pin* : "..lock_pin.."\n" .."*Warn English* : "..lock_english.."\n" .."*Warn Forward* : "..lock_forward.."\n" .."*Warn Arabic* : "..lock_arabic.."\n" .."*Warn Hashtag* : "..lock_htag.."\n".."*Warn tag* : "..lock_tag.."\n" .."*Warn Webpag* : "..lock_wp.."\n" .."*Warn Location* : "..lock_location.."\n"
.."*Warn Spam* : "..mute_spam.."\n" .."*Warn Photo* : "..mute_photo.."\n" .."*Warn Text* : "..mute_text.."\n" .."*Warn Gifs* : "..mute_gifs.."\n" .."*Warn Voice* : "..mute_voice.."\n" .."*Warn Music* : "..mute_music.."\n" .."*Warn Video* : "..mute_video.."\n*Warn Cmd* : "..lock_cmd.."\n"  .."*Warn Markdown* : "..mute_mdd.."\n*Warn Document* : "..mute_doc.."\n" 
.."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end


          local text = msg.content_.text_:gsub('اعدادات التحذير','sdd2')
  	 if text:match("^[Ss][Dd][Dd]2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallwarn'..msg.chat_id_) then
	mute_all = '`مفعل | 🔐`'
	else
	mute_all = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:text:warn'..msg.chat_id_) then
	mute_text = '`مفعل | 🔐`'
	else
	mute_text = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:photo:warn'..msg.chat_id_) then
	mute_photo = '`مفعل | 🔐`'
	else
	mute_photo = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:video:warn'..msg.chat_id_) then
	mute_video = '`مفعل | 🔐`'
	else
	mute_video = '`معطل | 🔓`'
end

	if database:get('bot:spam:warn'..msg.chat_id_) then
	mute_spam = '`مفعل | 🔐`'
	else
	mute_spam = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:gifs:warn'..msg.chat_id_) then
	mute_gifs = '`مفعل | 🔐`'
	else
	mute_gifs = '`معطل | 🔓`'
end
	------------
	if database:get('bot:music:warn'..msg.chat_id_) then
	mute_music = '`مفعل | 🔐`'
	else
	mute_music = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:inline:warn'..msg.chat_id_) then
	mute_in = '`مفعل | 🔐`'
	else
	mute_in = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:voice:warn'..msg.chat_id_) then
	mute_voice = '`مفعل | 🔐`'
	else
	mute_voice = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:links:warn'..msg.chat_id_) then
	mute_links = '`مفعل | 🔐`'
	else
	mute_links = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:sticker:warn'..msg.chat_id_) then
	lock_sticker = '`مفعل | 🔐`'
	else
	lock_sticker = '`معطل | 🔓`'
	end
	------------
   if database:get('bot:cmd:warn'..msg.chat_id_) then
	lock_cmd = '`مفعل | 🔐`'
	else
	lock_cmd = '`معطل | 🔓`'
end

    if database:get('bot:webpage:warn'..msg.chat_id_) then
	lock_wp = '`مفعل | 🔐`'
	else
	lock_wp = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:hashtag:warn'..msg.chat_id_) then
	lock_htag = '`مفعل | 🔐`'
	else
	lock_htag = '`معطل | 🔓`'
end
	if database:get('bot:pin:warn'..msg.chat_id_) then
	lock_pin = '`مفعل | 🔐`'
	else
	lock_pin = '`معطل | 🔓`'
	end 
	------------
    if database:get('bot:tag:warn'..msg.chat_id_) then
	lock_tag = '`مفعل | 🔐`'
	else
	lock_tag = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:location:warn'..msg.chat_id_) then
	lock_location = '`مفعل | 🔐`'
	else
	lock_location = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:contact:warn'..msg.chat_id_) then
	lock_contact = '`مفعل | 🔐`'
	else
	lock_contact = '`معطل | 🔓`'
	end

    if database:get('bot:english:warn'..msg.chat_id_) then
	lock_english = '`مفعل | 🔐`'
	else
	lock_english = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:arabic:warn'..msg.chat_id_) then
	lock_arabic = '`مفعل | 🔐`'
	else
	lock_arabic = '`معطل | 🔓`'
end

	if database:get('bot:document:warn'..msg.chat_id_) then
	mute_doc = '`مفعل | 🔐`'
	else
	mute_doc = '`معطل | 🔓`'
end

	if database:get('bot:markdown:warn'..msg.chat_id_) then
	mute_mdd = '`مفعل | 🔐`'
	else
	mute_mdd = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:forward:warn'..msg.chat_id_) then
	lock_forward = '`مفعل | 🔐`'
	else
	lock_forward = '`معطل | 🔓`'
end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`لا نهائي`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "✦┇ﮧ  `اعدادات المجموعه بالتحذير`\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  `كل الوسائط` : "..mute_all.."\n"
	 .."✦┇ﮧ  `الروابط` : "..mute_links.."\n"
	 .."✦┇ﮧ  `الانلاين` : "..mute_in.."\n"
	 .."✦┇ﮧ  `التثبيت` : "..lock_pin.."\n"
	 .."✦┇ﮧ  `اللغه الانكليزيه` : "..lock_english.."\n"
	 .."✦┇ﮧ  `اعاده التوجيه` : "..lock_forward.."\n"
	 .."✦┇ﮧ  `اللغه العربيه` : "..lock_arabic.."\n"
	 .."✦┇ﮧ  `التاكات` : "..lock_htag.."\n"
	 .."✦┇ﮧ  `المعرفات` : "..lock_tag.."\n" 
	 .."✦┇ﮧ  `المواقع` : "..lock_wp.."\n"
	 .."✦┇ﮧ  `الشبكات` : "..lock_location.."\n" 
   .."✦┇ﮧ  `الكلايش` : "..mute_spam.."\n\n" 
   .."✦┇ﮧ  `الصور` : "..mute_photo.."\n" 
   .."✦┇ﮧ  `الدردشه` : "..mute_text.."\n"
   .."✦┇ﮧ  `الصور المتحركه` : "..mute_gifs.."\n"
   .."✦┇ﮧ  `الملصقات` : "..lock_sticker.."\n"
	 .."✦┇ﮧ  `جهات الاتصال` : "..lock_contact.."\n" 
   .."✦┇ﮧ  `الصوتيات` : "..mute_voice.."\n" 
   .."✦┇ﮧ  `الاغاني` : "..mute_music.."\n" 
   .."✦┇ﮧ  `الفيديوهات` : "..mute_video.."\n✦┇ﮧ  `الشارحه` : "..lock_cmd.."\n"
   .."✦┇ﮧ  `الماركدون` : "..mute_mdd.."\n✦┇ﮧ  `الملفات` : "..mute_doc.."\n" 
   .."\n✦┇ﮧ  `انقضاء البوت` : "..exp_dat.." `يوم`\n" .."||ـ••••••••••••••••••••••••••••••••••••ـ||"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
  	 if text:match("^[Ss] [Bb][Aa][Nn]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallban'..msg.chat_id_) then
	mute_all = '`lock | 🔐`'
	else
	mute_all = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:text:ban'..msg.chat_id_) then
	mute_text = '`lock | 🔐`'
	else
	mute_text = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:photo:ban'..msg.chat_id_) then
	mute_photo = '`lock | 🔐`'
	else
	mute_photo = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:video:ban'..msg.chat_id_) then
	mute_video = '`lock | 🔐`'
	else
	mute_video = '`unlock | 🔓`'
end

	------------
	if database:get('bot:gifs:ban'..msg.chat_id_) then
	mute_gifs = '`lock | 🔐`'
	else
	mute_gifs = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:music:ban'..msg.chat_id_) then
	mute_music = '`lock | 🔐`'
	else
	mute_music = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:inline:ban'..msg.chat_id_) then
	mute_in = '`lock | 🔐`'
	else
	mute_in = '`unlock | 🔓`'
	end
	------------
	if database:get('bot:voice:ban'..msg.chat_id_) then
	mute_voice = '`lock | 🔐`'
	else
	mute_voice = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:links:ban'..msg.chat_id_) then
	mute_links = '`lock | 🔐`'
	else
	mute_links = '`unlock | 🔓`'
	end
    ------------
	if database:get('bot:sticker:ban'..msg.chat_id_) then
	lock_sticker = '`lock | 🔐`'
	else
	lock_sticker = '`unlock | 🔓`'
	end
	------------
   if database:get('bot:cmd:ban'..msg.chat_id_) then
	lock_cmd = '`lock | 🔐`'
	else
	lock_cmd = '`unlock | 🔓`'
end

    if database:get('bot:webpage:ban'..msg.chat_id_) then
	lock_wp = '`lock | 🔐`'
	else
	lock_wp = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:hashtag:ban'..msg.chat_id_) then
	lock_htag = '`lock | 🔐`'
	else
	lock_htag = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:tag:ban'..msg.chat_id_) then
	lock_tag = '`lock | 🔐`'
	else
	lock_tag = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:location:ban'..msg.chat_id_) then
	lock_location = '`lock | 🔐`'
	else
	lock_location = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:contact:ban'..msg.chat_id_) then
	lock_contact = '`lock | 🔐`'
	else
	lock_contact = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:english:ban'..msg.chat_id_) then
	lock_english = '`lock | 🔐`'
	else
	lock_english = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:arabic:ban'..msg.chat_id_) then
	lock_arabic = '`lock | 🔐`'
	else
	lock_arabic = '`unlock | 🔓`'
	end
	------------
    if database:get('bot:forward:ban'..msg.chat_id_) then
	lock_forward = '`lock | 🔐`'
	else
	lock_forward = '`unlock | 🔓`'
end

	if database:get('bot:document:ban'..msg.chat_id_) then
	mute_doc = '`lock | 🔐`'
	else
	mute_doc = '`unlock | 🔓`'
end

	if database:get('bot:markdown:ban'..msg.chat_id_) then
	mute_mdd = '`lock | 🔐`'
	else
	mute_mdd = '`unlock | 🔓`'
	end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`NO Fanil`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "*Group Settings Ban*\n======================\n*Ban all* : "..mute_all.."\n" .."*Ban Links* : "..mute_links.."\n" .."*Ban Inline* : "..mute_in.."\n" .."*Ban English* : "..lock_english.."\n" .."*Ban Forward* : "..lock_forward.."\n" .."*Ban Arabic* : "..lock_arabic.."\n" .."*Ban Hashtag* : "..lock_htag.."\n".."*Ban tag* : "..lock_tag.."\n" .."*Ban Webpage* : "..lock_wp.."\n" .."*Ban Location* : "..lock_location.."\n"
.."*Ban Photo* : "..mute_photo.."\n" .."*Ban Text* : "..mute_text.."\n" .."*Ban Gifs* : "..mute_gifs.."\n" .."*Ban Voice* : "..mute_voice.."\n" .."*Ban Music* : "..mute_music.."\n" .."*Ban Video* : "..mute_video.."\n*Ban Cmd* : "..lock_cmd.."\n"  .."*Ban Markdown* : "..mute_mdd.."\n*Ban Document* : "..mute_doc.."\n" 
.."*Expire* : "..exp_dat.."\n======================"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
    
          local text = msg.content_.text_:gsub('اعدادات الطرد','sdd3')
  	 if text:match("^[Ss][Dd][Dd]3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	if database:get('bot:muteallban'..msg.chat_id_) then
	mute_all = '`مفعل | 🔐`'
	else
	mute_all = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:text:ban'..msg.chat_id_) then
	mute_text = '`مفعل | 🔐`'
	else
	mute_text = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:photo:ban'..msg.chat_id_) then
	mute_photo = '`مفعل | 🔐`'
	else
	mute_photo = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:video:ban'..msg.chat_id_) then
	mute_video = '`مفعل | 🔐`'
	else
	mute_video = '`معطل | 🔓`'
end
	------------
	if database:get('bot:gifs:ban'..msg.chat_id_) then
	mute_gifs = '`مفعل | 🔐`'
	else
	mute_gifs = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:music:ban'..msg.chat_id_) then
	mute_music = '`مفعل | 🔐`'
	else
	mute_music = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:inline:ban'..msg.chat_id_) then
	mute_in = '`مفعل | 🔐`'
	else
	mute_in = '`معطل | 🔓`'
	end
	------------
	if database:get('bot:voice:ban'..msg.chat_id_) then
	mute_voice = '`مفعل | 🔐`'
	else
	mute_voice = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:links:ban'..msg.chat_id_) then
	mute_links = '`مفعل | 🔐`'
	else
	mute_links = '`معطل | 🔓`'
	end
    ------------
	if database:get('bot:sticker:ban'..msg.chat_id_) then
	lock_sticker = '`مفعل | 🔐`'
	else
	lock_sticker = '`معطل | 🔓`'
	end
	------------
   if database:get('bot:cmd:ban'..msg.chat_id_) then
	lock_cmd = '`مفعل | 🔐`'
	else
	lock_cmd = '`معطل | 🔓`'
end

    if database:get('bot:webpage:ban'..msg.chat_id_) then
	lock_wp = '`مفعل | 🔐`'
	else
	lock_wp = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:hashtag:ban'..msg.chat_id_) then
	lock_htag = '`مفعل | 🔐`'
	else
	lock_htag = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:tag:ban'..msg.chat_id_) then
	lock_tag = '`مفعل | 🔐`'
	else
	lock_tag = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:location:ban'..msg.chat_id_) then
	lock_location = '`مفعل | 🔐`'
	else
	lock_location = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:contact:ban'..msg.chat_id_) then
	lock_contact = '`مفعل | 🔐`'
	else
	lock_contact = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:english:ban'..msg.chat_id_) then
	lock_english = '`مفعل | 🔐`'
	else
	lock_english = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:arabic:ban'..msg.chat_id_) then
	lock_arabic = '`مفعل | 🔐`'
	else
	lock_arabic = '`معطل | 🔓`'
	end
	------------
    if database:get('bot:forward:ban'..msg.chat_id_) then
	lock_forward = '`مفعل | 🔐`'
	else
	lock_forward = '`معطل | 🔓`'
end

	if database:get('bot:document:ban'..msg.chat_id_) then
	mute_doc = '`مفعل | 🔐`'
	else
	mute_doc = '`معطل | 🔓`'
end

	if database:get('bot:markdown:ban'..msg.chat_id_) then
	mute_mdd = '`مفعل | 🔐`'
	else
	mute_mdd = '`معطل | 🔓`'
	end
	------------
	------------
	local ex = database:ttl("bot:charge:"..msg.chat_id_)
                if ex == -1 then
				exp_dat = '`لا نهائي`'
				else
				exp_dat = math.floor(ex / 86400) + 1
			    end
 	------------
	 local TXT = "✦┇ﮧ  `اعدادات المجموعه بالطرد`\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  `كل الوسائط` : "..mute_all.."\n"
	 .."✦┇ﮧ  `الروابط` : "..mute_links.."\n" 
	 .."✦┇ﮧ  `الانلاين` : "..mute_in.."\n"
	 .."✦┇ﮧ  `اللغه الانكليزيه` : "..lock_english.."\n"
	 .."✦┇ﮧ  `اعاده التوجيه` : "..lock_forward.."\n" 
	 .."✦┇ﮧ  `اللغه العربيه` : "..lock_arabic.."\n"
	 .."✦┇ﮧ  `التاكات` : "..lock_htag.."\n"
	 .."✦┇ﮧ  `المعرفات` : "..lock_tag.."\n" 
	 .."✦┇ﮧ  `المواقع` : "..lock_wp.."\n" 
	 .."✦┇ﮧ  `الشبكات` : "..lock_location.."\n\n"
   .."✦┇ﮧ  `الصور` : "..mute_photo.."\n" 
   .."✦┇ﮧ  `الدردشه` : "..mute_text.."\n" 
   .."✦┇ﮧ  `الصور المتحركه` : "..mute_gifs.."\n" 
   .."✦┇ﮧ  `الملصقات` : "..lock_sticker.."\n"
	 .."✦┇ﮧ  `جهات الاتصال` : "..lock_contact.."\n" 
   .."✦┇ﮧ  `الصوتيات` : "..mute_voice.."\n"
   .."✦┇ﮧ  `الاغاني` : "..mute_music.."\n"  
   .."✦┇ﮧ  `الفيديوهات` : "..mute_video.."\n✦┇ﮧ  `الشارحه` : "..lock_cmd.."\n"
   .."✦┇ﮧ  `الماركدون` : "..mute_mdd.."\n✦┇ﮧ  `الملفات` : "..mute_doc.."\n" 
   .."✦┇ﮧ  `انقضاء البوت` : "..exp_dat.." `يوم`\n" .."||ـ••••••••••••••••••••••••••••••••••••ـ||"
         send(msg.chat_id_, msg.id_, 1, TXT, 1, 'md')
    end
     
  ----------------------------------------------------------------------------------------------- 
if text:match("^المطور$") or text:match("^المطورين$") or text:match("^مطور البوت$") or text:match("^مطور$") then
   
   local text =  [[
🔖| Welcome My Dear
🔖| My Name Is TSHAKE
🔖| Dev @TH3CZAR
]]
                send(msg.chat_id_, msg.id_, 1, text, 1,  "html" )
   end
  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('ت المطور','change ph')
if text:match("^[Cc][Hh][Aa][Nn][Gg][Ee] [Pp][Hh]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Now send the_ *developer number*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الان يمكنك ارسال رقم المطور` 🗳', 1, 'md')
end
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
end
if text:match("^+(.*)$") then
local kekoo = redis:get('sudoo'..text..''..bot_id)
local keko2 = redis:get('nkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Now send the_ *name of the developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الان يمكنك ارسال الاسم الذي تريده` 🏷', 1, 'md')
end
redis:set('nmkeko'..bot_id, text)  
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'mmsg')  
  return false end  
end
if text:match("^(.*)$") then
local keko2 = redis:get('nkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'mmsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved Send a_ *DEV to watch the changes*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم حفظ الاسم يمكنك اظهار الجه بـ ارسال امر المطور` ☑️', 1, 'md')
end
redis:set('nkeko'..msg.sender_user_id_..''..bot_id, 'no')  
redis:set('nakeko'..bot_id, text)  
local nmkeko = redis:get('nmkeko'..bot_id)
sendContact(msg.chat_id_, msg.id_, 0, 1, nil, nmkeko, text , "", bot_id)
  return false end  
end
  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('اضف مطور','add sudo')
if text:match("^[Aa][Dd][Dd] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send ID_ *Developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الان يمكنك ارسال ايدي المطور الذي تريد رفعه`💡', 1, 'md')
end
redis:set('qkeko'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
end
if text:match("^(%d+)$") then
local kekoo = redis:get('sudoo'..text..''..bot_id)
local keko2 = redis:get('qkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Has been added_ '..text..' *Developer of bot*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم اضافته`  '..text..' `مطور للبوت`☑️', 1, 'md')
end
redis:set('sudoo'..text..''..bot_id, 'yes')  
redis:sadd('dev'..bot_id, text)
redis:set('qkeko'..msg.sender_user_id_..''..bot_id, 'no')  
  return false end  
end  

  for k,v in pairs(sudo_users) do
local text = msg.content_.text_:gsub('حذف مطور','rem sudo')
if text:match("^[Rr][Ee][Mm] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send ID_ *Developer*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الان يمكنك ارسال ايدي المطور الذي تريد حذفه`🗑', 1, 'md')
end
redis:set('xkeko'..msg.sender_user_id_..''..bot_id, 'nomsg')  
  return false end  
end
if text:match("^(%d+)$") then
local keko2 = redis:get('xkeko'..msg.sender_user_id_..''..bot_id)
if keko2 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Has been removed_ '..text..' *Developer of bot*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم حذفه`  '..text..' `من مطورين البوت`💯️', 1, 'md')
end
redis:set('xkeko'..msg.sender_user_id_..''..bot_id, 'no')  
redis:del('sudoo'..text..''..bot_id, 'no')  
 end  
end

local text = msg.content_.text_:gsub('اضف رد','add rep')
if text:match("^[Aa][Dd][Dd] [Rr][Ee][Pp]$") and is_owner(msg.sender_user_id_ , msg.chat_id_) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  ارسل الكلمه التي تريد اضافتها 📬', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'msg')  
  return false end  
if text:match("^(.*)$") then
if not database:get('bot:repowner:mute'..msg.chat_id_) then
local keko = redis:get('keko'..text..''..bot_id..''..msg.chat_id_..'')
send(msg.chat_id_, msg.id_, 1, keko, 1, 'md')
end
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
if keko1 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the reply_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  الان ارسل الرد الذي تريد اضافته 📭', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 're')  
redis:set('msg'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', text)  
redis:sadd('repowner'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', text)  
  return false end  
if keko1 == 're' then
local keko2 = redis:get('msg'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
redis:set('keko'..keko2..''..bot_id..''..msg.chat_id_..'', text)  
redis:sadd('kekore'..bot_id..''..msg.chat_id_..'', keko2)
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `تم حفظ الرد` ☑️", 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'no')  
end
end  

local text = msg.content_.text_:gsub('حذف رد','rem rep')
if text:match("^[Rr][Ee][Mm] [Rr][Ee][Pp]$") and is_owner(msg.sender_user_id_ , msg.chat_id_) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to remov*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  ارسل الكلمه التي تريد حذفها 🗑', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'nomsg')  
  return false end  
if text:match("^(.*)$") then
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'')
if keko1 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Deleted_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  تم حذف الرد 💯️', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id..''..msg.chat_id_..'', 'no')  
redis:set('keko'..text..''..bot_id..''..msg.chat_id_..'', " ")  
 end  
end

local text = msg.content_.text_:gsub('اضف رد للكل','add rep all')
if text:match("^[Aa][Dd][Dd] [Rr][Ee][Pp] [Aa][Ll][Ll]$") and is_sudo(msg) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  ارسل الكلمه التي تريد اضافتها 📬', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'msg')  
  return false end  
if text:match("^(.*)$") then
if not database:get('bot:repsudo:mute'..msg.chat_id_) then
local keko = redis:get('keko'..text..''..bot_id)
send(msg.chat_id_, msg.id_, 1, keko, 1, 'md')
end
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id)
if keko1 == 'msg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the reply_ *you want to add*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  الان ارسل الرد الذي تريد اضافته 📭', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 're')  
redis:set('msg'..msg.sender_user_id_..''..bot_id, text)  
  return false end  
if keko1 == 're' then
local keko2 = redis:get('msg'..msg.sender_user_id_..''..bot_id)
redis:set('keko'..keko2..''..bot_id, text)  
redis:sadd('kekoresudo'..bot_id, keko2)
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Saved_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `تم حفظ الرد` ☑️", 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'no')  
end
end  
 
local text = msg.content_.text_:gsub('حذف رد للكل','rem rep all')
if text:match("^[Rr][Ee][Mm] [Rr][Ee][Pp] [Aa][Ll][Ll]$") and is_sudo(msg) then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Send the word_ *you want to remov*', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  ارسل الكلمه التي تريد حذفها 🗑', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'nomsg')  
  return false end  
if text:match("^(.*)$") then
local keko1 = redis:get('keko1'..msg.sender_user_id_..''..bot_id)
if keko1 == 'nomsg' then
if database:get('lang:gp:'..msg.chat_id_) then
send(msg.chat_id_, msg.id_, 1, '_> Deleted_', 1, 'md')
else
send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  تم حذف الرد 💯️', 1, 'md')
end
redis:set('keko1'..msg.sender_user_id_..''..bot_id, 'no')  
 redis:set('keko'..text..''..bot_id..'', " ")  
 end  
end

local text = msg.content_.text_:gsub('مسح المطورين','clean sudo')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Ss][Uu][Dd][Oo]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
  local list = redis:smembers('dev'..bot_id)
  for k,v in pairs(list) do
redis:del('dev'..bot_id, text)
redis:del('sudoo'..v..''..bot_id, 'no')  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Bot developers_ *have been cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `تم مسح مطورين البوت` 🗑", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('مسح ردود المدير','clean rep owner')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Rr][Ee][Pp] [Oo][Ww][Nn][Ee][Rr]$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local list = redis:smembers('kekore'..bot_id..''..msg.chat_id_..'')
  for k,v in pairs(list) do
redis:del('kekore'..bot_id..''..msg.chat_id_..'', text)
redis:set('keko'..v..''..bot_id..''..msg.chat_id_..'', " ")  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Owner replies_ *cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `تم مسح ردود المدير` 🗑", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('مسح ردود المطور','clean rep sudo')
if text:match("^[Cc][Ll][Ee][Aa][Nn] [Rr][Ee][Pp] [Ss][Uu][Dd][Oo]$") and is_sudo(msg) then
  local list = redis:smembers('kekoresudo'..bot_id)
  for k,v in pairs(list) do
redis:del('kekoresudo'..bot_id, text)
redis:set('keko'..v..''..bot_id..'', " ")  
end
if database:get('lang:gp:'..msg.chat_id_) then
  send(msg.chat_id_, msg.id_, 1, '_> Sudo replies_ *cleared*', 1, 'md')
else 
  send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `تم مسح ردود المطور` 🗑", 1, 'md')
    end
  end

local text = msg.content_.text_:gsub('المطورين','sudo list')
if text:match("^[Ss][Uu][Dd][Oo] [Ll][Ii][Ss][Tt]$") and tonumber(msg.sender_user_id_) == tonumber(sudo_add) then
	local list = redis:smembers('dev'..bot_id)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>Sudo List :</b>\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  ✅ :- added\n✦┇ﮧ  ❎ :- Deleted\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n"
else 
  text = "✦┇ﮧ  <code>قائمه المطورين </code>⬇️ :\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  ✅ :- تم رفعه\n✦┇ﮧ  ❎ :- تم تنزيله\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n"
  end
	for k,v in pairs(list) do
			local keko11 = redis:get('sudoo'..v..''..bot_id)
			local botlua = "❎"
       if keko11 == 'yes' then
       botlua = "✅"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>Sudo List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد مطورين</code> 💯️"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

local text = msg.content_.text_:gsub('ردود المطور','rep sudo list')
if text:match("^[Rr][Ee][Pp] [Ss][Uu][Dd][Oo] [Ll][Ii][Ss][Tt]$") and is_sudo(msg) then
	local list = redis:smembers('kekoresudo'..bot_id)
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>rep sudo List :</b>\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  ✅ :- Enabled\n✦┇ﮧ  ❎ :- Disabled\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n"
else 
  text = "✦┇ﮧ  <code>قائمه ردود المطور </code>⬇️ :\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  ✅ :- مفعله\n✦┇ﮧ  ❎ :- معطله\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n"
  end
	for k,v in pairs(list) do
  local keko11 = redis:get('keko'..v..''..bot_id)
			local botlua = "✅"
       if keko11 == ' ' then
       botlua = "❎"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>rep sudo List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد ردود للمطور</code> 💯️"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end

local text = msg.content_.text_:gsub('ردود المدير','rep owner list')
if text:match("^[Rr][Ee][Pp] [Oo][Ww][Nn][Ee][Rr] [Ll][Ii][Ss][Tt]$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local list = redis:smembers('kekore'..bot_id..''..msg.chat_id_..'')
  if database:get('lang:gp:'..msg.chat_id_) then
  text = "<b>rep owner List :</b>\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  ✅ :- Enabled\n✦┇ﮧ  ❎ :- Disabled\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n"
else 
  text = "✦┇ﮧ  <code>قائمه ردود المدير </code>⬇️ :\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n✦┇ﮧ  ✅ :- مفعله\n✦┇ﮧ  ❎ :- معطله\n||ـ••••••••••••••••••••••••••••••••••••ـ||\n"
  end
	for k,v in pairs(list) do
    local keko11 = redis:get('keko'..v..''..bot_id..''..msg.chat_id_..'')
			local botlua = "✅"
       if keko11 == ' ' then
       botlua = "❎"
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		else
  if database:get('lang:gp:'..msg.chat_id_) then
    	text = text..k.." - "..v.." - "..botlua.."\n"
    			else
			text = text..k.." - "..v.." - "..botlua.."\n"
			end
		end
	end
	if #list == 0 then
	   if database:get('lang:gp:'..msg.chat_id_) then
                text = "<b>rep owner List is empty !</b>"
              else 
                text = "✦┇ﮧ  <code>لا يوجد ردود للمدير</code> 💯️"
end
    end
	send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('كرر','echo')
  	if text:match("^echo (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(echo) (.*)$")} 
         send(msg.chat_id_, msg.id_, 1, txt[2], 1, 'md')
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع قوانين','setrules')
  	if text:match("^[Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Ee][Tt][Rr][Uu][Ll][Ee][Ss]) (.*)$")}
	database:set('bot:rules'..msg.chat_id_, txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, "*> Group rules upadted..._", 1, 'md')
   else 
         send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `تم وضع القوانين للمجموعه` 📍☑️", 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
  	if text:match("^[Rr][Uu][Ll][Ee][Ss]$")or text:match("^القوانين$") then
	local rules = database:get('bot:rules'..msg.chat_id_)
	if rules then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Group Rules :*\n'..rules, 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `قوانين المجموعه هي  :` ⬇️\n'..rules, 1, 'md')
end
    else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*rules msg not saved!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `لم يتم حفظ قوانين للمجموعه` 💯️❌', 1, 'md')
end
	end
	end
	-----------------------------------------------------------------------------------------------
     local text = msg.content_.text_:gsub('وضع اسم','setname')
		if text:match("^[Ss][Ee][Tt][Nn][Aa][Mm][Ee] (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Ee][Tt][Nn][Aa][Mm][Ee]) (.*)$")}
	     changetitle(msg.chat_id_, txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Group name updated!_\n'..txt[2], 1, 'md')
       else
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تحديث اسم المجموعه الى ✔️⬇️`\n'..txt[2], 1, 'md')
         end
    end
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Ee][Tt][Pp][Hh][Oo][Tt][Oo]$") or text:match("^وضع صوره") and is_owner(msg.sender_user_id_, msg.chat_id_) then
          database:set('bot:setphoto'..msg.chat_id_..':'..msg.sender_user_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Please send a photo noew!_', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `قم بارسال صوره الان` ✔️📌', 1, 'md')
end
    end
	-----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('وضع وقت','setexpire')
	if text:match("^[Ss][Ee][Tt][Ee][Xx][Pp][Ii][Rr][Ee] (%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
		local a = {string.match(text, "^([Ss][Ee][Tt][Ee][Xx][Pp][Ii][Rr][Ee]) (%d+)$")} 
		 local time = a[2] * day
         database:setex("bot:charge:"..msg.chat_id_,time,true)
		 database:set("bot:enable:"..msg.chat_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Group Charged for_ *'..a[2]..'* _Days_', 1, 'md')
else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع وقت انتهاء البوت` *'..a[2]..'* `يوم` 💯️❌', 1, 'md')
end
  end
  
	-----------------------------------------------------------------------------------------------
	if text:match("^[Ss][Tt][Aa][Tt][Ss]$") or text:match("^الوقت$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
    local ex = database:ttl("bot:charge:"..msg.chat_id_)
       if ex == -1 then
                if database:get('lang:gp:'..msg.chat_id_) then
		send(msg.chat_id_, msg.id_, 1, '_No fanil_', 1, 'md')
else 
		send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `وقت المجموعه لا نهائي` ☑️', 1, 'md')
end
       else
        local d = math.floor(ex / day ) + 1
                if database:get('lang:gp:'..msg.chat_id_) then
	   		send(msg.chat_id_, msg.id_, 1, d.." *Group Days*", 1, 'md')
else 
send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `عدد ايام وقت المجموعه` ⬇️\n"..d.." `يوم` 📍", 1, 'md')
end
       end
    end
	-----------------------------------------------------------------------------------------------
    
	if text:match("^وقت المجموعه (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^(وقت المجموعه) (-%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `وقت المجموعه لا نهائي` ☑️', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `عدد ايام وقت المجموعه` ⬇️\n"..d.." `يوم` 📍", 1, 'md')
       end
    end
    
	if text:match("^[Ss][Tt][Aa][Tt][Ss] [Gg][Pp] (-%d+)") and is_admin(msg.sender_user_id_, msg.chat_id_) then
	local txt = {string.match(text, "^([Ss][Tt][Aa][Tt][Ss] [Gg][Pp]) (-%d+)$")} 
    local ex = database:ttl("bot:charge:"..txt[2])
       if ex == -1 then
		send(msg.chat_id_, msg.id_, 1, '_No fanil_', 1, 'md')
       else
        local d = math.floor(ex / day ) + 1
	   		send(msg.chat_id_, msg.id_, 1, d.." *Group is Days*", 1, 'md')
       end
    end
	-----------------------------------------------------------------------------------------------
	 if is_sudo(msg) then
  -----------------------------------------------------------------------------------------------
  if text:match("^[Ll][Ee][Aa][Vv][Ee] (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^([Ll][Ee][Aa][Vv][Ee]) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '*Group* '..txt[2]..' *remov*', 1, 'md')
	   send(txt[2], 0, 1, '*Error*\n_Group is not my_', 1, 'md')
	   chat_leave(txt[2], bot_id)
  end
  
  if text:match("^مغادره (-%d+)$") and is_admin(msg.sender_user_id_, msg.chat_id_) then
  	local txt = {string.match(text, "^(مغادره) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `المجموعه` '..txt[2]..' `تم الخروج منها` ☑️📍', 1, 'md')
	   send(txt[2], 0, 1, '✦┇ﮧ  `هذه ليست ضمن المجموعات الخاصة بي` 💯️❌', 1, 'md')
	   chat_leave(txt[2], bot_id)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^المده1 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(المده1) (-%d+)$")} 
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `المجموعه` '..txt[2]..' `تم اعادة تفعيلها المدة 30 يوم ☑️📍`', 1, 'md')
	   send(txt[2], 0, 1, '✦┇ﮧ  `تم تفعيل مدة المجموعه 30 يوم` ✔️📌', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "✦┇ﮧ  `قام بتفعيل مجموعه المده كانت 30 يوم ☑️` : \n✦┇ﮧ  `ايدي المطور 📍` : "..msg.sender_user_id_.."\n✦┇ﮧ  `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n✦┇ﮧ  `معلومات المجموعه 👥` :\n\n✦┇ﮧ  `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n✦┇ﮧ  `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]1 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]1) (-%d+)$")} 
       local timeplan1 = 2592000
       database:setex("bot:charge:"..txt[2],timeplan1,true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done 30 Days Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done 30 Days Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^المده2 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(المده2) (-%d+)$")} 
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `المجموعه` '..txt[2]..' `تم اعادة تفعيلها المدة 90 يوم ☑️📍`', 1, 'md')
	   send(txt[2], 0, 1, '✦┇ﮧ  `تم تفعيل مدة المجموعه 90 يوم` ✔️📌', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "✦┇ﮧ  `قام بتفعيل مجموعه المده كانت 90 يوم ☑️` : \n✦┇ﮧ  `ايدي المطور 📍` : "..msg.sender_user_id_.."\n✦┇ﮧ  `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n✦┇ﮧ  `معلومات المجموعه 👥` :\n\n✦┇ﮧ  `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n✦┇ﮧ  `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
-------------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]2 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]2) (-%d+)$")} 
       local timeplan2 = 7776000
       database:setex("bot:charge:"..txt[2],timeplan2,true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done 90 Days Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done 90 Days Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^المده3 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^(المده3) (-%d+)$")} 
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `المجموعه` '..txt[2]..' `تم اعادة تفعيلها المدة لا نهائية ☑️📍`', 1, 'md')
	   send(txt[2], 0, 1, '✦┇ﮧ  `تم تفعيل مدة المجموعه لا نهائية` ✔️📌', 1, 'md')
	   for k,v in pairs(sudo_users) do
            send(v, 0, 1, "✦┇ﮧ  `قام بتفعيل مجموعه المده كانت لا نهائية ☑️` : \n✦┇ﮧ  `ايدي المطور 📍` : "..msg.sender_user_id_.."\n✦┇ﮧ  `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n✦┇ﮧ  `معلومات المجموعه 👥` :\n\n✦┇ﮧ  `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n✦┇ﮧ  `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
  if text:match('^[Pp][Ll][Aa][Nn]3 (-%d+)$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Pp][Ll][Aa][Nn]3) (-%d+)$")} 
       database:set("bot:charge:"..txt[2],true)
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *Done Days No Fanil Active*', 1, 'md')
	   send(txt[2], 0, 1, '*Done Days No Fanil Active*', 1, 'md')
	   for k,v in pairs(sudo_users) do
	      send(v, 0, 1, "*User "..msg.sender_user_id_.." Added bot to new group*" , 1, 'md')
       end
	   database:set("bot:enable:"..txt[2],true)
  end
  -----------------------------------------------------------------------------------------------
local text = msg.content_.text_:gsub('تفعيل','add')
  if text:match('^[Aa][Dd][Dd]$') and is_sudo(msg) then
  local keko22 = ''..config2.t..''..config2.keko[19]..':'..config2.keko[1]..''..config2.keko[2]..''..config2.keko[3]..''..config2.keko[4]..''..config2.keko[5]..''..config2.keko[6]..''..config2.keko[7]..''..config2.keko[8]..''..config2.keko[9]..''..config2.keko[10]..''..config2.keko[11]..''..config2.keko[12]..''..config2.keko[13]..''..config2.keko[14]..''..config2.keko[15]..''..config2.keko[16]..''..config2.keko[17]..''..config2.keko[18]..''..config2.t2..''..msg.sender_user_id_..''
  local ress = https.request(keko22)
  local jrees = JSON.decode(ress)
  if jrees.description == 'Bad Request: USER_ID_INVALID' then 
  print(config2.to)
  send(msg.chat_id_, msg.id_, 1, config2.telegram, 1, 'md')
  return false end
  local txt = {string.match(text, "^([Aa][Dd][Dd])$")} 
  if database:get("bot:charge:"..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Bot is already Added Group*', 1, 'md')
    else
        send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `المجموعه [ "..chat.title_.." ] مفعله سابقا` ☑️", 1, 'md')
end
                  end
       if not database:get("bot:charge:"..msg.chat_id_) then
       database:set("bot:charge:"..msg.chat_id_,true)
                if database:get('lang:gp:'..msg.chat_id_) then
	   send(msg.chat_id_, msg.id_, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Bot Added To Group*", 1, 'md')
   else 
        send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `ايديك 📍 :` _"..msg.sender_user_id_.."_\n✦┇ﮧ  `تم` ✔️ `تفعيل المجموعه [ "..chat.title_.." ]` ☑️", 1, 'md')
end
	   for k,v in pairs(sudo_users) do
                if database:get('lang:gp:'..msg.chat_id_) then
	      send(v, 0, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> added bot to new group*" , 1, 'md')
      else  
            send(v, 0, 1, "✦┇ﮧ  `قام بتفعيل مجموعه جديده ☑️` : \n✦┇ﮧ  `ايدي المطور 📍` : "..msg.sender_user_id_.."\n✦┇ﮧ  `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n✦┇ﮧ  `معلومات المجموعه 👥` :\n\n✦┇ﮧ  `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n✦┇ﮧ  `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
end
       end
	   database:set("bot:enable:"..msg.chat_id_,true)
  end
end
  -----------------------------------------------------------------------------------------------
          local text = msg.content_.text_:gsub('تعطيل','rem')
  if text:match('^[Rr][Ee][Mm]$') and is_sudo(msg) then
       local txt = {string.match(text, "^([Rr][Ee][Mm])$")} 
      if not database:get("bot:charge:"..msg.chat_id_) then
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Bot is already remove Group*', 1, 'md')
    else 
        send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `المجموعه [ "..chat.title_.." ] معطله سابقا` 💯️", 1, 'md')
end
                  end
      if database:get("bot:charge:"..msg.chat_id_) then
       database:del("bot:charge:"..msg.chat_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
	   send(msg.chat_id_, msg.id_, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Bot Removed To Group!*", 1, 'md')
   else 
        send(msg.chat_id_, msg.id_, 1, "✦┇ﮧ  `ايديك 📍 :` _"..msg.sender_user_id_.."_\n✦┇ﮧ  `تم` ✔️ `تعطيل المجموعه [ "..chat.title_.." ]` 💯️", 1, 'md')
end
	   for k,v in pairs(sudo_users) do
                if database:get('lang:gp:'..msg.chat_id_) then
	      send(v, 0, 1, "*> Your ID :* _"..msg.sender_user_id_.."_\n*> Removed bot from new group*" , 1, 'md')
      else 
            send(v, 0, 1, "✦┇ﮧ  `قام بتعطيل مجموعه 💯️` : \n✦┇ﮧ  `ايدي المطور 📍` : "..msg.sender_user_id_.."\n✦┇ﮧ  `معرف المطور 🚹` : "..get_info(msg.sender_user_id_).."\n\n✦┇ﮧ  `معلومات المجموعه 👥` :\n\n✦┇ﮧ  `ايدي المجموعه 🚀` : "..msg.chat_id_.."\n✦┇ﮧ  `اسم المجموعه 📌` : "..chat.title_ , 1, 'md')
end
       end
  end
  end
              
  -----------------------------------------------------------------------------------------------
   if text:match('^[Jj][Oo][Ii][Nn] (-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^([Jj][Oo][Ii][Nn]) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '_Group_ '..txt[2]..' *is join*', 1, 'md')
	   send(txt[2], 0, 1, '*Sudo Joined To Grpup*', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
  -----------------------------------------------------------------------------------------------
   if text:match('^اضافه (-%d+)') and is_admin(msg.sender_user_id_, msg.chat_id_) then
       local txt = {string.match(text, "^(اضافه) (-%d+)$")} 
	   send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `المجموعه` '..txt[2]..' `تم اضافتك لها ` ☑️', 1, 'md')
	   send(txt[2], 0, 1, '✦┇ﮧ  `تم اضافه المطور للمجموعه` ✔️📍', 1, 'md')
	   add_user(txt[2], msg.sender_user_id_, 10)
  end
   -----------------------------------------------------------------------------------------------
  end
	-----------------------------------------------------------------------------------------------
     if text:match("^[Dd][Ee][Ll]$")  and is_mod(msg.sender_user_id_, msg.chat_id_) or text:match("^مسح$") and msg.reply_to_message_id_ ~= 0 and is_mod(msg.sender_user_id_, msg.chat_id_) then
     delete_msg(msg.chat_id_, {[0] = msg.reply_to_message_id_})
     delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
	----------------------------------------------------------------------------------------------
   if text:match('^تنظيف (%d+)$') and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local matches = {string.match(text, "^(تنظيف) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
      pm = '✦┇ﮧ  <code> لا تستطيع حذف اكثر من 100 رساله ❗️💯️</code>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])}, delmsg, nil)
      pm ='✦┇ﮧ  <i>[ '..matches[2]..' ]</i> <code>من الرسائل تم حذفها ☑️❌</code>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='✦┇ﮧ  <code> هناك خطا<code> 💯️'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
              end
            end


   if text:match('^[Dd]el (%d+)$') and is_owner(msg.sender_user_id_, msg.chat_id_) then
  local matches = {string.match(text, "^([Dd]el) (%d+)$")}
   if msg.chat_id_:match("^-100") then
    if tonumber(matches[2]) > 100 or tonumber(matches[2]) < 1 then
      pm = '<b>> Error</b>\n<b>use /del [1-1000] !<bb>'
    send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                  else
      tdcli_function ({
     ID = "GetChatHistory",
       chat_id_ = msg.chat_id_,
          from_message_id_ = 0,
   offset_ = 0,
          limit_ = tonumber(matches[2])
    }, delmsg, nil)
      pm ='> <i>'..matches[2]..'</i> <b>Last Msgs Has Been Removed.</b>'
           send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
       end
        else pm ='<b>> found!<b>'
      send(msg.chat_id_, msg.id_, 1, pm, 1, 'html')
                end
              end

          local text = msg.content_.text_:gsub('حفظ','note')
    if text:match("^[Nn][Oo][Tt][Ee] (.*)$") and is_sudo(msg) then
    local txt = {string.match(text, "^([Nn][Oo][Tt][Ee]) (.*)$")}
      database:set('owner:note1', txt[2])
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*save!*', 1, 'md')
    else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم حفظ الكليشه ☑️`', 1, 'md')
end
    end

    if text:match("^[Dd][Nn][Oo][Tt][Ee]$") or text:match("^حذف الكليشه$") and is_sudo(msg) then
      database:del('owner:note1',msg.chat_id_)
                if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '*Deleted!*', 1, 'md')
    else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم حذف الكليشه 💯️`', 1, 'md')
end
      end
  -----------------------------------------------------------------------------------------------
    if text:match("^[Gg][Ee][Tt][Nn][Oo][Tt][Ee]$") and is_sudo(msg) or text:match("^جلب الكليشه$") and is_sudo(msg) then
    local note = database:get('owner:note1')
	if note then
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Note is :-*\n'..note, 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الكليشه المحفوظه ⬇️ :`\n'..note, 1, 'md')
end
    else
                if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '*Note msg not saved!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `لا يوجد كليشه محفوظه 💯️`', 1, 'md')
end
	end
end

  if text:match("^[Ss][Ee][Tt][Ll][Aa][Nn][Gg] (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^تحويل (.*)$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
    local langs = {string.match(text, "^(.*) (.*)$")}
  if langs[2] == "ar" or langs[2] == "عربيه" then
  if not database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `بالفعل تم وضع اللغه العربيه للبوت 💯️`', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم وضع اللغه العربيه للبوت في المجموعه ☑️`', 1, 'md')
       database:del('lang:gp:'..msg.chat_id_)
    end
    end
  if langs[2] == "en" or langs[2] == "انكليزيه" then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '_> Language Bot is already_ *English*', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '> _Language Bot has been changed to_ *English* !', 1, 'md')
        database:set('lang:gp:'..msg.chat_id_,true)
    end
    end
end
----------------------------------------------------------------------------------------------

  if text == "unlock reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تفعيل ردود البوت" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:rep:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot is already enabled*️', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ردود البوت بالفعل تم تفعيلها` ☑️', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot has been enable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تفعيل ردود البوت` ☑️', 1, 'md')
       database:del('bot:rep:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply bot" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تعطيل ردود البوت" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:rep:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot is already disabled*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ردود البوت بالفعل تم تعطيلها` 💯️', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies bot has been disable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تعطيل ردود البوت` 💯️', 1, 'md')
        database:set('bot:rep:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------

  if text == "unlock reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تفعيل ردود المطور" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:repsudo:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo is already enabled*️', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ردود المطور بالفعل تم تفعيلها` ☑️', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo has been enable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تفعيل ردود المطور` ☑️', 1, 'md')
       database:del('bot:repsudo:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply sudo" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تعطيل ردود المطور" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:repsudo:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo is already disabled*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ردود المطور بالفعل تم تعطيلها` 💯️', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies sudo has been disable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تعطيل ردود المطور` 💯️', 1, 'md')
        database:set('bot:repsudo:mute'..msg.chat_id_,true)
      end
    end
  end
  
  if text == "unlock reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock Reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تفعيل ردود المدير" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:repowner:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner is already enabled*️', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ردود المدير بالفعل تم تفعيلها` ☑️', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner has been enable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تفعيل ردود المدير` ☑️', 1, 'md')
       database:del('bot:repowner:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock Reply owner" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تعطيل ردود المدير" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:repowner:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner is already disabled*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `ردود المدير بالفعل تم تعطيلها` 💯️', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *Replies owner has been disable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تعطيل ردود المدير` 💯️', 1, 'md')
        database:set('bot:repowner:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------
   if text:match("^[Ii][Dd][Gg][Pp]$") or text:match("^ايدي المجموعه$") then
    send(msg.chat_id_, msg.id_, 1, "*"..msg.chat_id_.."*", 1, 'md')
  end
	-----------------------------------------------------------------------------------------------
  if text == "unlock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Unlock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تفعيل الايدي" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if not database:get('bot:id:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID is already enabled*️', 1, 'md')
else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الايدي بالفعل تم تفعيله` ☑️', 1, 'md')
      end
  else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID has been enable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تفعيل الايدي` ☑️', 1, 'md')
       database:del('bot:id:mute'..msg.chat_id_)
      end
    end
    end
  if text == "lock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "Lock id" and is_owner(msg.sender_user_id_, msg.chat_id_) or text == "تعطيل الايدي" and is_owner(msg.sender_user_id_, msg.chat_id_) then
  if database:get('bot:id:mute'..msg.chat_id_) then
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID is already disabled*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الايدي بالفعل تم تعطيله` 💯️', 1, 'md')
      end
    else
  if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, '> *ID has been disable*️', 1, 'md')
    else
      send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تعطيل الايدي` 💯️', 1, 'md')
        database:set('bot:id:mute'..msg.chat_id_,true)
      end
    end
  end
	-----------------------------------------------------------------------------------------------
if  text:match("^[Ii][Dd]$") and msg.reply_to_message_id_ == 0 or text:match("^ايدي$") and msg.reply_to_message_id_ == 0 then
local function getpro(extra, result, success)
local user_msgs = database:get('user:msgs'..msg.chat_id_..':'..msg.sender_user_id_)
   if result.photos_[0] then
      if is_sudo(msg) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Sudo'
      else
      t = 'مطور البوت 👑'
      end
      elseif is_admin(msg.sender_user_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Global Admin'
      else
      t = 'ادمن في البوت 👮️'
      end
      elseif is_owner(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Owner'
      else
      t = 'مدير الكروب 👨️'
      end
      elseif is_mod(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Moderator'
      else
      t = 'ادمن للكروب 💂'
      end
      elseif is_vip(msg.sender_user_id_, msg.chat_id_) then
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Moderator'
      else
      t = 'عضو مميز 🏆'
      end
      else
      if database:get('lang:gp:'..msg.chat_id_) then
      t = 'Group Member'
      else
      t = 'مجرد عضو 🐍️'
      end
    end
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"> Group ID : "..msg.chat_id_.."\n> Your ID : "..msg.sender_user_id_.."\n> UserName : "..get_info(msg.sender_user_id_).."\n> Your Rank : "..t.."\n> Msgs : "..user_msgs,msg.id_,msg.id_.."")
  else 
            sendPhoto(msg.chat_id_, msg.id_, 0, 1, nil, result.photos_[0].sizes_[1].photo_.persistent_id_,"●》 ايدي المجموعه 💬 》 "..msg.chat_id_.."\n●》ايديك  🔖》 "..msg.sender_user_id_.."\n●》معرفك 🔖》 "..get_info(msg.sender_user_id_).."\n●》موقعك 🔖》"..t.."\n●》رسائلك 🔖》 "..user_msgs,msg.id_,msg.id_.."")
end
else 
      end
   else
         if not database:get('bot:id:mute'..msg.chat_id_) then
          if database:get('lang:gp:'..msg.chat_id_) then
      send(msg.chat_id_, msg.id_, 1, "You Have'nt Profile Photo!!\n\n> *> Group ID :* "..msg.chat_id_.."\n*> Your ID :* "..msg.sender_user_id_.."\n*> UserName :* "..get_info(msg.sender_user_id_).."\n*> Msgs : *_"..user_msgs.."_", 1, 'md')
   else 
      send(msg.chat_id_, msg.id_, 1, "●》`انت لا تملك صوره لحسابك ` 🐸️\n\n●》` ايدي المجموعه ` 💬 》 "..msg.chat_id_.."\n●》` ايديك ` 🔖 》 "..msg.sender_user_id_.."\n●》` معرفك ` 🔖 》 "..get_info(msg.sender_user_id_).."\n●》` رسائلك `🔖 》 _"..user_msgs.."_", 1, 'md')
end
else 
      end
   end
   end
   tdcli_function ({
    ID = "GetUserProfilePhotos",
    user_id_ = msg.sender_user_id_,
    offset_ = 0,
    limit_ = 1
  }, getpro, nil)
end

   if text:match('^الحساب (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^الحساب (%d+)$')
        local text = 'اضغط لمشاهده الحساب'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end 

   if text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$') and is_mod(msg.sender_user_id_, msg.chat_id_) then
        local id = text:match('^[Ww][Hh][Oo][Ii][Ss] (%d+)$')
        local text = 'Click to view user!'
      tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=19, user_id_=id}}}}, dl_cb, nil)
   end
          local text = msg.content_.text_:gsub('معلومات','res')
          if text:match("^[Rr][Ee][Ss] (.*)$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
            local memb = {string.match(text, "^([Rr][Ee][Ss]) (.*)$")}
            function whois(extra,result,success)
                if result.username_ then
             result.username_ = '@'..result.username_
               else
             result.username_ = 'لا يوجد معرف'
               end
              if database:get('lang:gp:'..msg.chat_id_) then
                send(msg.chat_id_, msg.id_, 1, '> *Name* :'..result.first_name_..'\n> *Username* : '..result.username_..'\n> *ID* : '..msg.sender_user_id_, 1, 'md')
              else
                send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `الاسم` 📌 : '..result.first_name_..'\n✦┇ﮧ  `المعرف` 🚹 : '..result.username_..'\n✦┇ﮧ  `الايدي` 📍 : '..msg.sender_user_id_, 1, 'md')
              end
            end
            getUser(memb[2],whois)
          end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Pp][Ii][Nn]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^تثبيت$") and is_owner(msg.sender_user_id_, msg.chat_id_) then
        local id = msg.id_
        local msgs = {[0] = id}
       pin(msg.chat_id_,msg.reply_to_message_id_,0)
	   database:set('pinnedmsg'..msg.chat_id_,msg.reply_to_message_id_)
          if database:get('lang:gp:'..msg.chat_id_) then
	            send(msg.chat_id_, msg.id_, 1, '_Msg han been_ *pinned!*', 1, 'md')
	           else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم تثبيت الرساله` ☑️', 1, 'md')
end
 end

   if text:match("^[Vv][Ii][Ee][Ww]$") or text:match("^مشاهده منشور$") then
        database:set('bot:viewget'..msg.sender_user_id_,true)
    if database:get('lang:gp:'..msg.chat_id_) then
        send(msg.chat_id_, msg.id_, 1, '*Please send a post now!*', 1, 'md')
      else 
        send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `قم بارسال المنشور الان` ❗️', 1, 'md')
end
   end
  end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Uu][Nn][Pp][Ii][Nn]$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^الغاء تثبيت$") and is_owner(msg.sender_user_id_, msg.chat_id_) or text:match("^الغاء التثبيت") and is_owner(msg.sender_user_id_, msg.chat_id_) then
         unpinmsg(msg.chat_id_)
          if database:get('lang:gp:'..msg.chat_id_) then
         send(msg.chat_id_, msg.id_, 1, '_Pinned Msg han been_ *unpinned!*', 1, 'md')
       else 
         send(msg.chat_id_, msg.id_, 1, '✦┇ﮧ  `تم الغاء تثبيت الرساله` 💯️', 1, 'md')
end
   end
   -----------------------------------------------------------------------------------------------
   if text:match("^[Hh][Ee][Ll][Pp]$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
`هناك`  *6* `اوامر لعرضها`
*======================*
*h1* `لعرض اوامر الحمايه`
*======================*
*h2* `لعرض اوامر الحمايه بالتحذير`
*======================*
*h3* `لعرض اوامر الحمايه بالطرد`
*======================*
*h4* `لعرض اوامر الادمنيه`
*======================*
*h5* `لعرض اوامر المجموعه`
*======================*
*h6* `لعرض اوامر المطورين`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `للقفل`
*unlock* `للفتح`
*======================*
*| links |* `الروابط`
*| tag |* `المعرف`
*| hashtag |* `التاك`
*| cmd |* `السلاش`
*| edit |* `التعديل`
*| webpage |* `الروابط الخارجيه`
*======================*
*| flood ban |* `التكرار بالطرد`
*| flood mute |* `التكرار بالكتم`
*| flood del |* `التكرار بالمسح`
*| gif |* `الصور المتحركه`
*| photo |* `الصور`
*| sticker |* `الملصقات`
*| video |* `الفيديو`
*| inline |* `لستات شفافه`
*======================*
*| text |* `الدردشه`
*| fwd |* `التوجيه`
*| music |* `الاغاني`
*| voice |* `الصوت`
*| contact |* `جهات الاتصال`
*| service |* `اشعارات الدخول`
*| markdown |* `الماركدون`
*| file |* `الملفات`
*======================*
*| location |* `المواقع`
*| bots |* `البوتات`
*| spam |* `الكلايش`
*| arabic |* `العربيه`
*| english |* `الانكليزيه`
*| reply bot |* `ردود البوت`
*| reply sudo |* `ردود المطور`
*| reply owner |* `ردود المدير`
*| id |* `الايدي`
*| all |* `كل الميديا`
*| all |* `مع العدد قفل الميديا بالثواني`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `للقفل`
*unlock* `للفتح`
*======================*
*| links warn |* `الروابط`
*| tag warn |* `المعرف`
*| hashtag warn |* `التاك`
*| cmd warn |* `السلاش`
*| webpage warn |* `الروابط الخارجيه`
*======================*
*| gif warn |* `الصور المتحركه`
*| photo warn |* `الصور`
*| sticker warn |* `الملصقات`
*| video warn |* `الفيديو`
*| inline warn |* `لستات شفافه`
*======================*
*| text warn |* `الدردشه`
*| fwd warn |* `التوجيه`
*| music warn |* `الاغاني`
*| voice warn |* `الصوت`
*| contact warn |* `جهات الاتصال`
*| markdown warn |* `الماركدون`
*| file warn |* `الملفات`
*======================*
*| location warn |* `المواقع`
*| spam |* `الكلايش`
*| arabic warn |* `العربيه`
*| english warn |* `الانكليزيه`
*| all warn |* `كل الميديا`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*lock* `للقفل`
*unlock* `للفتح`
*======================*
*| links ban |* `الروابط`
*| tag ban |* `المعرف`
*| hashtag ban |* `التاك`
*| cmd ban |* `السلاش`
*| webpage ban |* `الروابط الخارجيه`
*======================*
*| gif ban |* `الصور المتحركه`
*| photo ban |* `الصور`
*| sticker ban |* `الملصقات`
*| video ban |* `الفيديو`
*| inline ban |* `لستات شفافه`
*| markdown ban |* `الماركدون`
*| file ban |* `الملفات`
*======================*
*| text ban |* `الدردشه`
*| fwd ban |* `التوجيه`
*| music ban |* `الاغاني`
*| voice ban |* `الصوت`
*| contact ban |* `جهات الاتصال`
*| location ban |* `المواقع`
*======================*
*| arabic ban |* `العربيه`
*| english ban |* `الانكليزيه`
*| all ban |* `كل الميديا`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*======================*
*| setmote |* `رفع ادمن` 
*| remmote |* `ازاله ادمن` 
*| setvip |* `رفع عضو مميز` 
*| remvip |* `ازاله عضو مميز` 
*| setlang en |* `تغير اللغه للانكليزيه` 
*| setlang ar |* `تغير اللغه للعربيه` 
*| unsilent |* `لالغاء كتم العضو` 
*| silent |* `لكتم عضو` 
*| ban |* `حظر عضو` 
*| unban |* `الغاء حظر العضو` 
*| kick |* `طرد عضو` 
*| id |* `لاظهار الايدي [بالرد] `
*| pin |* `تثبيت رساله!`
*| unpin |* `الغاء تثبيت الرساله!`
*| res |* `معلومات حساب بالايدي` 
*| whois |* `مع الايدي لعرض صاحب الايدي`
*======================*
*| s del |* `اظهار اعدادات المسح`
*| s warn |* `اظهار اعدادات التحذير`
*| s ban |* `اظهار اعدادات الطرد`
*| silentlist |* `اظهار المكتومين`
*| banlist |* `اظهار المحظورين`
*| modlist |* `اظهار الادمنيه`
*| viplist |* `اظهار الاعضاء المميزين`
*| del |* `حذف رساله بالرد`
*| link |* `اظهار الرابط`
*| rules |* `اظهار القوانين`
*======================*
*| bad |* `منع كلمه` 
*| unbad |* `الغاء منع كلمه` 
*| badlist |* `اظهار الكلمات الممنوعه` 
*| stats |* `لمعرفه ايام البوت`
*| del wlc |* `حذف الترحيب` 
*| set wlc |* `وضع الترحيب` 
*| wlc on |* `تفعيل الترحيب` 
*| wlc off |* `تعطيل الترحيب` 
*| get wlc |* `معرفه الترحيب الحالي` 
*| add rep |* `اضافه رد` 
*| rem rep |* `حذف رد` 
*| rep owner list |* `اظهار ردود المدير` 
*| clean rep owner |* `مسح ردو المدير` 
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end

   if text:match("^[Hh]5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
*======================*
*clean* `مع الاوامر ادناه بوضع فراغ`

*| banlist |* `المحظورين`
*| badlist |* `كلمات المحظوره`
*| modlist |* `الادمنيه`
*| viplist |* `الاعضاء المميزين`
*| link |* `الرابط المحفوظ`
*| silentlist |* `المكتومين`
*| bots |* `بوتات تفليش وغيرها`
*| rules |* `القوانين`
*======================*
*set* `مع الاوامر ادناه بدون فراغ`

*| link |* `لوضع رابط`
*| rules |* `لوضع قوانين`
*| name |* `مع الاسم لوضع اسم`
*| photo |* `لوضع صوره`

*======================*

*| flood ban |* `وضع تكرار بالطرد`
*| flood mute |* `وضع تكرار بالكتم`
*| flood del |* `وضع تكرار بالكتم`
*| flood time |* `لوضع زمن تكرار بالطرد او الكتم`
*| spam del |* `وضع عدد السبام بالمسح`
*| spam warn |* `وضع عدد السبام بالتحذير`
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^[Hh]6$") and is_sudo(msg) then
   
   local text =  [[
*======================*
*| add |* `تفعيل البوت`
*| rem |* `تعطيل البوت`
*| setexpire |* `وضع ايام للبوت`
*| stats gp |* `لمعرفه ايام البوت`
*| plan1 + id |* `تفعيل البوت 30 يوم`
*| plan2 + id |* `تفعيل البوت 90 يوم`
*| plan3 + id |* `تفعيل البوت لا نهائي`
*| join + id |* `لاضافتك للكروب`
*| leave + id |* `لخروج البوت`
*| leave |* `لخروج البوت`
*| stats gp + id |* `لمعرفه  ايام البوت`
*| view |* `لاظهار مشاهدات منشور`
*| note |* `لحفظ كليشه`
*| dnote |* `لحذف الكليشه`
*| getnote |* `لاظهار الكليشه`
*| reload |* `لتنشيط البوت`
*| clean gbanlist |* `لحذف الحظر العام`
*| clean owners |* `لحذف قائمه المدراء`
*| adminlist |* `لاظهار ادمنيه البوت`
*| gbanlist |* `لاظهار المحظورين عام `
*| ownerlist |* `لاظهار مدراء البوت`
*| setadmin |* `لاضافه ادمن`
*| remadmin |* `لحذف ادمن`
*| setowner |* `لاضافه مدير`
*| remowner |* `لحذف مدير`
*| banall |* `لحظر العام`
*| unbanall |* `لالغاء العام`
*| invite |* `لاضافه عضو`
*| groups |* `عدد كروبات البوت`
*| bc |* `لنشر شئ`
*| del |* `ويه العدد حذف رسائل`
*| add sudo |* `اضف مطور`
*| rem sudo |* `حذف مطور`
*| add rep all |* `اضف رد لكل المجموعات`
*| rem rep all |* `حذف رد لكل المجموعات`
*| change ph |* `تغير جهه المطور`
*| sudo list |* `اظهار المطورين` 
*| rep sudo list |* `اظهار ردود المطور` 
*| clean sudo |* `مسح المطورين` 
*| clean rep sudo |* `مسح ردود المطور` 
*======================*
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   
   
   if text:match("^الاوامر$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
👮¦ـ مرحبا عزيزي في الاوامر العامه
||ـ••••••••••••••••••••••••••••••••••••ـ||

▪️||م1 : اوامر الحمايه بالمسح ....🔏

▫️||م2 : اوامر الحمايه بالتحذير ..⚠️

▪️||م3 : اوامر الحمايه بالطرد........👞

▫️||م4 : لعرض اوامر الادمنيه.......✴️

▪️||م5 : لعرض اوامر المجموعه ..💬

▫️||م6 : لعرض اوامر المطورين....👑
||ـ••••••••••••••••••••••••••••••••••••ـ||
❕||للاستفسار:- @TH3CZAR
🔆||تواصل محضورين:- @CONTACT4BOT
||ـ••••••••••••••••••••••••••••••••••••ـ||
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^م1$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
🚨¦ـ مرحبآ بك في اوامر المسح
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ  قفل 《 لقفل امر》 🔐
💫¦ـ  فتح 《 لفتح امر》 🔓
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الروابط ..........................🔏
💫¦ـ المعرف...................................🔏
💫¦ـ التاك.......................................🔏
💫¦ـ الشارحه.................................🔏
💫¦ـ التعديل..................................🔏
💫¦ـ التثبيت..................................🔏
💫¦ـ المواقع...................................🔏
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ التكرار بالطرد........................🔏
💫¦ـ التكرار بالكتم........................🔏
💫¦ـالتكرار بالمسح.......................🔏
💫¦ـ المتحركه...............................🔏
💫¦ـ الملفات..................................🔏
💫¦ـ الصور....................................🔏
💫¦ـ الملصقات..............................🔏
💫¦ـ الفيديو..................................🔏
💫¦ـ الانلاين..................................🔏
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الدردشه.................................🔏
💫¦ـ التوجيه..................................🔏
💫¦ـ الاغاني...................................🔏
💫¦ـ الصوت...................................🔏
💫¦ـ الجهات...................................🔏
💫¦ـ الماركدون...............................🔏
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الاشعارات..............................🔏
💫¦ـ الشبكات.................................🔏
💫¦ـ البوتات..................................🔏
💫¦ـ الكلايش................................🔏
💫¦ـ العربيه...................................🔏
💫¦ـ الانكليزيه..............................🔏
💫¦ـ الكل.......................................🔏
💫¦ـ الكل بالثواني + العدد...........⏳
💫¦ـ الكل بالساعه  + العدد...........⏳
||ـ••••••••••••••••••••••••••••••••••••ـ||
💬¦ راسلني للاستفسار 💡
💬¦ـ  @TH3CZAR
💬¦ للمحظورين للتواصل من هنا 👇
💬¦ـ @CONTACT4BOT
||ـ••••••••••••••••••••••••••••••••••••ـ||
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
    
   if text:match("^م2$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
🚨¦ـ مرحبآ بك في اوامر التحذير
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ  قفل 《 لقفل امر》 🔐
💫¦ـ  فتح 《 لفتح امر》 🔓
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الروابط بالتحذير ..............⚠️
💫¦ـ المعرف بالتحذير...................⚠️
💫¦ـ التاك بالتحذير.......................⚠️
💫¦ـ الشارحه بالتحذير.................⚠️
💫¦ـ التثبيت بالتحذير..................⚠️
💫¦ـ المواقع بالتحذير...................⚠️
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ المتحركه بالتحذير................⚠️
💫¦ـ الملفات بالتحذير...................⚠️
💫¦ـ الصور بالتحذير.....................⚠️
💫¦ـ الملصقات بالتحذير...............⚠️
💫¦ـ الفيديو بالتحذير...................⚠️
💫¦ـ الانلاين بالتحذير..................⚠️
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الدردشه بالتحذير.................⚠️
💫¦ـ التوجيه بالتحذير..................⚠️
💫¦ـ الاغاني بالتحذير...................⚠️
💫¦ـ الصوت بالتحذير...................⚠️
💫¦ـ الجهات بالتحذير..................⚠️
💫¦ـ الماركدون بالتحذير..............⚠️
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الشبكات بالتحذير................⚠️
💫¦ـ الكلايش بالتحذير................⚠️
💫¦ـ العربيه بالتحذير...................⚠️
💫¦ـ الانكليزيه بالتحذير..............⚠️
💫¦ـ الكل بالتحذير.......................⚠️
||ـ••••••••••••••••••••••••••••••••••••ـ||
💬¦ راسلني للاستفسار 💡
💬¦ـ  @TH3CZAR
💬¦ للمحظورين للتواصل من هنا 👇
💬¦ـ @CONTACT4BOT
||ـ••••••••••••••••••••••••••••••••••••ـ||
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^م3$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
🚨¦ـ مرحبآ بك في اوامر الطرد
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ  قفل 《لقفل امر 》 🔐
💫¦ـ  فتح 《لفتح امر 》 🔓
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الروابط بالطرد......................👞
💫¦ـ المعرف بالطرد......................👞
💫¦ـ التاك بالطرد..........................👞
💫¦ـ الشارحه بالطرد....................👞
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ المتحركه بالطرد..................👞
💫¦ـ الملفات بالطرد.....................👞
💫¦ـ الصور بالطرد.......................👞
💫¦ـ الملصقات بالطرد.................👞
💫¦ـ الفيديو بالطرد.....................👞
💫¦ـ الانلاين بالطرد.....................👞
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الدردشه بالطرد...................👞
💫¦ـ التوجيه بالطرد....................👞
💫¦ـ الاغاني بالطرد.....................👞
💫¦ـ الصوت بالطرد.....................👞
💫¦ـ الجهات بالطرد.....................👞
💫¦ـ الماركدون بالطرد.................👞
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ الشبكات بالطرد...................👞
💫¦ـ الكلايش بالطرد...................👞
💫¦ـ العربيه بالطرد......................👞
💫¦ـ الانكليزيه بالطرد.................👞
💫¦ـ الكل بالطرد..........................👞
||ـ••••••••••••••••••••••••••••••••••••ـ||
💬¦ راسلني للاستفسار 💡
💬¦ـ  @TH3CZAR
💬¦ للمحظورين للتواصل من هنا 👇
💬¦ـ @CONTACT4BOT
||ـ••••••••••••••••••••••••••••••••••••ـ||
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^م4$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
🚨¦ـ مرحبآ بك في اوامر الادمنيه
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ اعدادات المسح
💫¦ـ اعدادات التحذير
💫¦ـ اعدادات الطرد
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ المكتومين
💫¦ـ المحظورين
💫¦ـ قائمه المنع
💫¦ـ الاعضاء المميزين
💫¦ـ الادمنيه
💫¦ـ مسح + رد
💫¦ـ ايدي + رد
💫¦ـ الرابط
💫¦ـ القوانين
💫¦ـ طرد
💫¦ـ الوقت
💫¦ـ جلب الترحيب
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ تفعيل ردود البوت
💫¦ـ تعطيل ردود البوت
💫¦ـ تفعيل ردود المدير
💫¦ـ تعطيل ردود المدير
💫¦ـ تفعيل ردود المطور
💫¦ـ تعطيل ردود المطور
💫¦ـ معلومات + ايدي
💫¦ـ الحساب  + ايدي
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ  رفع ادمن••••••••••  تنزيل ادمن
💫¦ـ رفع عضومميز••تنزيل عضومميز
💫¦ـ تحويل انكليزيه••••تحويل عربيه
💫¦ـ كتم •••••••••••••••••••الغاء كتم
💫¦ـ حظر •••••••••••••••••الغاء حظر
💫¦ـ تثبيت ••••••••••••••الغاء تثبيت
💫¦ـ اضف رد  ••••••••••••••حذف رد
💫¦ـ منع + الكلمه••الغاء منع + الكلمه
💫¦ـ وضع الترحيب••••حذف الترحيب
💫¦ـ تفعيل الترحيب••تعطيل الترحيب
💫¦ـ ردود المدير••••مسح ردود المدير
💫¦ـ تفعيل الايدي••••••تعطيل الايدي
||ـ••••••••••••••••••••••••••••••••••••ـ||
💬¦ راسلني للاستفسار 💡
💬¦ـ  @TH3CZAR
💬¦ للمحظورين للتواصل من هنا 👇
💬¦ـ @CONTACT4BOT
||ـ••••••••••••••••••••••••••••••••••••ـ||
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end

   if text:match("^م5$") and is_mod(msg.sender_user_id_, msg.chat_id_) then
   
   local text =  [[
🚨¦ـ مرحبآ بك في اوامر المجموعه
||ـ••••••••••••••••••••••••••••••••••••ـ||
💯¦ـ  مسح《مع الاوامر ادناه》
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ  المحظورين 
💫¦ـ قائمه المنع
💫¦ـ الادمنيه
💫¦ـ الاعضاء المميزين
💫¦ـ الرابط
💫¦ـ المكتومين
💫¦ـ البوتات
💫¦ـ القوانين
||ـ••••••••••••••••••••••••••••••••••••ـ||
💯¦ـ وضع《مع الاوامر ادناه》
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ رابط
💫¦ـ قوانين
💫¦ـ اسم
💫¦ـ صوره
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ وضع تكرار بالطرد       + العدد
💫¦ـ وضع تكرار بالكتم       + العدد
💫¦ـ وضع تكرار بالمسح     + العدد
💫¦ـ وضع زمن التكرار        + العدد
💫¦ـ وضع كلايش بالمسح   + العدد
💫¦ـ وضع كلايش بالتحذير + العدد
||ـ••••••••••••••••••••••••••••••••••••ـ||
💬¦ راسلني للاستفسار 💡
💬¦ـ  @TH3CZAR
💬¦ للمحظورين للتواصل من هنا 👇
💬¦ـ @CONTACT4BOT
||ـ••••••••••••••••••••••••••••••••••••ـ||
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
   if text:match("^م6$") and is_sudo(msg) then
   
   local text =  [[
🚨¦ـ مرحبآ بك في اوامر المطور
||ـ••••••••••••••••••••••••••••••••••••ـ||
💯¦ـ  تفعيل ✔️
💯¦ـ  تعطيل ❌
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ مشاهده منشور
💫¦ـ حفظ
💫¦ـ تحديث
💫¦ـ ادمنيه البوت
💫¦ـ الكروبات
💫¦ـ اضافه
💫¦ـ رفع ادمن للبوت    
💫¦ـ تنزيل ادمن للبوت 
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ المده1             + id
💫¦ـ المده2             + id
💫¦ـ المده3             + id
💫¦ـ اضافه              + id
💫¦ـ وقت المجموعه + id
💫¦ـ  وضع وقت       + عدد 
💫¦ـ تنظيف             + عدد
||ـ••••••••••••••••••••••••••••••••••••ـ||
💫¦ـ المدراء   ••••••••••••••• الادمنيه
💫¦ـ رفع مدير ••••••••••• تنزيل مدير
💫¦ـ حظر عام •••••••••••• الغاء العام
💫¦ـ اضف مطور ••••••• حذف مطور 
💫¦ـ المطورين  ••••• مسح المطورين
💫¦ـ ردود المطور •مسح ردود المطور
💫¦ـ اضف رد للكل•••• حذف رد للكل
💫¦ـ مغادره ••••••••••• مغادره + id
💫¦ـ جلب الكليشه•••••حذف الكليشه
💫¦ـ مسح المدراء•••• مسح الادمنيه
💫¦ـ قائمه العام •••• مسح قائمه العام
||ـ••••••••••••••••••••••••••••••••••••ـ||
💬¦ راسلني للاستفسار 💡
💬¦ـ  @TH3CZAR
💬¦ للمحظورين للتواصل من هنا 👇
💬¦ـ @CONTACT4BOT
||ـ••••••••••••••••••••••••••••••••••••ـ||
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'md')
   end
   
if text:match("^source$") or text:match("^اصدار$") or text:match("^الاصدار$") or text:match("^السورس$") or text:match("^سورس$") then
   
     local text =  [[
اشترك في قناة البوت لطفأ
https://t.me/joinchat/AAAAAEO21tNt8_pzyhTpgw
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end

if text:match("^اريد رابط حذف$") or text:match("^رابط حذف$") or text:match("^رابط الحذف$") or text:match("^الرابط حذف$") or text:match("^اريد رابط الحذف$") then
   
   local text =  [[
✦┇ﮧ  رابط حذف التلي ⬇️ ֆ
✦┇ﮧ  احذف ولا ترجع عيش حياتك 😾💚ֆ
✦┇ﮧ  https://telegram.org/deactivate
]]
                send(msg.chat_id_, msg.id_, 1, text, 1, 'html')
   end
  -----------------------------------------------------------------------------------------------
 end
  -----------------------------------------------------------------------------------------------
                                       -- end code --
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateChat") then
    chat = data.chat_
    chats[chat.id_] = chat
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateMessageEdited") then
   local msg = data
  -- vardump(msg)
  	function get_msg_contact(extra, result, success)
	local text = (result.content_.text_ or result.content_.caption_)
    --vardump(result)
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
	end
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or
text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or
text:match("[Tt][Ee][Ll][Ee][Ss][Cc][Oo].[Pp][Ee]") then
   if database:get('bot:links:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end

   if text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]") or
text:match("[Tt].[Mm][Ee]") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]") or
text:match("[Tt][Ee][Ll][Ee][Ss][Cc][Oo].[Pp][Ee]") then
   if database:get('bot:links:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>ممنوع عمل تعديل للروابط</code> 💯️", 1, 'html')
	end
end
end

	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("[Hh][Tt][Tt][Pp][Ss]://") or text:match("[Hh][Tt][Tt][Pp]://") or text:match(".[Ii][Rr]") or text:match(".[Cc][Oo][Mm]") or text:match(".[Oo][Rr][Gg]") or text:match(".[Ii][Nn][Ff][Oo]") or text:match("[Ww][Ww][Ww].") or text:match(".[Tt][Kk]") then
   if database:get('bot:webpage:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	
   if database:get('bot:webpage:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>ممنوع عمل تعديل للمواقع</code> 💯️", 1, 'html')
	end
end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("@") then
   if database:get('bot:tag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:tag:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>ممنوع عمل تعديل للمعرفات</code> 💯️", 1, 'html')
	end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("#") then
   if database:get('bot:hashtag:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:hashtag:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>ممنوع عمل تعديل للتاكات</code> 💯️", 1, 'html')
	end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("/")  then
   if database:get('bot:cmd:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:cmd:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>ممنوع عمل تعديل للشارحه</code> 💯️", 1, 'html')
	end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   	if text:match("[\216-\219][\128-\191]") then
   if database:get('bot:arabic:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	end
	   if database:get('bot:arabic:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>ممنوع عمل تعديل  للغه العربيه</code> 💯️", 1, 'html')
	end
 end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
   if text:match("[ASDFGHJKLQWERTYUIOPZXCVBNMasdfghjklqwertyuiopzxcvbnm]") then
   if database:get('bot:english:mute'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
	end
	   if database:get('bot:english:warn'..result.chat_id_) then
    local msgs = {[0] = data.message_id_}
       delete_msg(msg.chat_id_,msgs)
                            send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>ممنوع عمل تعديل  للغه الانكليزيه</code> 💯️", 1, 'html')
end
end
end
end
	if result.id_ and result.content_.text_ then
	database:set('bot:editid'..result.id_,result.content_.text_)
  if not is_mod(result.sender_user_id_, result.chat_id_) then
   check_filter_words(result, text)
	if database:get('editmsg'..msg.chat_id_) == 'delmsg' then
        local id = msg.message_id_
        local msgs = {[0] = id}
        local chat = msg.chat_id_
              delete_msg(chat,msgs)
              send(msg.chat_id_, 0, 1, "✦┇ﮧ  <code>ممنوع التعديل هنا</code> 💯️", 1, 'html')
	elseif database:get('editmsg'..msg.chat_id_) == 'didam' then
	if database:get('bot:editid'..msg.message_id_) then
		local old_text = database:get('bot:editid'..msg.message_id_)
     send(msg.chat_id_, msg.message_id_, 1, '✦┇ﮧ  `لقد قمت بالتعديل` ❌\n\n✦┇ﮧ `رسالتك السابقه ` ⬇️  : \n\n✦┇ﮧ  [ '..old_text..' ]', 1, 'md')
	end
end 
end
end
    end
	end

    getMessage(msg.chat_id_, msg.message_id_,get_msg_contact)
  -----------------------------------------------------------------------------------------------
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({ID="GetChats", offset_order_="9223372036854775807", offset_chat_id_=0, limit_=20}, dl_cb, nil)    
  end
  -----------------------------------------------------------------------------------------------
end

--[[                                    Dev @lIMyIl         
   _____    _        _    _    _____    Dev @EMADOFFICAL 
  |_   _|__| |__    / \  | | _| ____|   Dev @h_k_a  
    | |/ __| '_ \  / _ \ | |/ /  _|     Dev @IX00XI
    | |\__ \ | | |/ ___ \|   <| |___    Dev @H_173
    |_||___/_| |_/_/   \_\_|\_\_____|   Dev @lIESIl
              CH > @CHTH3CZAR
--]]
