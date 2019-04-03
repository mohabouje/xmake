--!A cross-platform build utility based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2019, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        rustc.lua
--

-- imports
import("core.base.option")
import("core.project.config")
import("core.project.project")

-- init it
function init(self)
    
    -- init arflags
    self:set("rc-arflags", "--crate-type=lib")

    -- init shflags
    self:set("rc-shflags", "--crate-type=dylib")

    -- init ldflags
    self:set("rc-ldflags", "--crate-type=bin")

    -- init the file formats
    self:set("formats", { static = "lib$(name).rlib" })

    -- init buildmodes
    self:set("buildmodes", 
    {
        ["object:sources"] = false  -- compile multiple source filess to the single object
    ,   ["binary:sources"] = true   -- build multiple source files to the binary target file
    ,   ["static:sources"] = true   -- build multiple source files to the static target file
    ,   ["shared:sources"] = true   -- build multiple source files to the shared target file
    })
end

-- make the optimize flag
function nf_optimize(self, level)

    -- the maps
    local maps = 
    {   
        none        = "-C opt-level=0"
    ,   fast        = "-C opt-level=1"
    ,   faster      = "-C opt-level=2"
    ,   fastest     = "-C opt-level=3"
    ,   smallest    = "-C opt-level=s"
    ,   aggressive  = "-C opt-level=z"
    }

    -- make it
    return maps[level] 
end

-- make the symbol flag
function nf_symbol(self, level)

    -- the maps
    local maps = 
    {   
        debug = "-C debuginfo=2"
    }

    -- make it
    return maps[level] 
end

-- make the linkdir flag
function nf_linkdir(self, dir)
    return "-L" .. os.args(dir)
end

-- make the build arguments list
function buildargv(self, sourcefiles, targetkind, targetfile, flags)
    return self:program(), table.join(flags, "-o", targetfile, sourcefiles)
end

-- build the target file
function build(self, sourcefiles, targetkind, targetfile, flags)

    -- ensure the target directory
    os.mkdir(path.directory(targetfile))

    -- build it
    os.runv(buildargv(self, sourcefiles, targetkind, targetfile, flags))
end

-- make the complie arguments list
function compargv(self, sourcefiles, objectfile, flags)
    return self:program(), table.join("--emit", "obj", flags, "-o", objectfile, sourcefiles)
end

-- complie the source file
function compile(self, sourcefiles, objectfile, dependinfo, flags)

    -- ensure the object directory
    os.mkdir(path.directory(objectfile))

    -- compile it
    os.runv(compargv(self, sourcefiles, objectfile, flags))
end

