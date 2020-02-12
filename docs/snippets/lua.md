```
for k,v in pairs(resp_user.header) do
    -- ngx.header[k] = v
    ngx.say(k .. ' ' .. v)
end
```