library UniqueStack /* v1.0.0.6
************************************************************************************
*
*   module UniqueStack
*
*       Description
*       -------------------------
*
*           Node Properties:
*
*               Unique
*               Allocated
*               Not 0
*
*       Fields
*       -------------------------
*
*           readonly static integer sentinel
*
*           readonly thistype first
*           readonly thistype next
*
*       Methods
*       -------------------------
*
*           static method create takes nothing returns thistype
*           method destroy takes nothing returns nothing
*
*           method push takes thistype node returns nothing
*           method pop takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module UniqueStack
        private static integer instanceCount = 0
        private static integer array recycler
        debug private boolean isNode
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,    "UniqueStack", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,   "UniqueStack", "next", "thistype", this, "Attempted To Read Rogue Node.")
            return _next
        endmethod
        
        private thistype _first
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,            "UniqueStack", "first", "thistype", this, "Attempted To Read Null Stack.")
            debug call ThrowError(recycler[this] != -1, "UniqueStack", "first", "thistype", this, "Attempted To Read Invalid Stack.")
            return _first
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = recycler[0]
            
            if (this == 0) then
                debug call ThrowError(instanceCount == 8191, "UniqueStack", "create", "thistype", 0, "Overflow.")
            
                set this = instanceCount + 1
                set instanceCount = this
            else
                set recycler[0] = recycler[this]
            endif
            
            debug set recycler[this] = -1
            
            return this
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = _first
        
            debug call ThrowError(this == 0,            "UniqueStack", "clear", "thistype", this, "Attempted To Clear Null Stack.")
            debug call ThrowError(recycler[this] != -1, "UniqueStack", "clear", "thistype", this, "Attempted To Clear Invalid Stack.")
        
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node._next
                endloop
            endif
        
            set _first = 0
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "UniqueStack", "destroy", "thistype", this, "Attempted To Destroy Null Stack.")
            debug call ThrowError(recycler[this] != -1, "UniqueStack", "destroy", "thistype", this, "Attempted To Destroy Invalid Stack.")
            
            debug call clear()
            
            set recycler[this] = recycler[0]
            set recycler[0] = this
            set _first = 0
        endmethod
        method push takes thistype node returns nothing
            debug call ThrowError(this == 0,            "UniqueStack", "push", "thistype", this, "Attempted To Push (" + I2S(node) + ") On To Null Stack.")
            debug call ThrowError(recycler[this] != -1, "UniqueStack", "push", "thistype", this, "Attempted To Push (" + I2S(node) + ") On To Invalid Stack.")
            debug call ThrowError(node == 0,            "UniqueStack", "push", "thistype", this, "Attempted To Push Null Node.")
            debug call ThrowError(node.isNode,          "UniqueStack", "push", "thistype", this, "Attempted To Push Owned Node (" + I2S(node) + ").")
            
            debug set node.isNode = true
        
            set node._next = _first
            set _first = node
        endmethod
        method pop takes nothing returns nothing
            debug call ThrowError(this == 0,            "UniqueStack", "pop", "thistype", this, "Attempted To Pop Null Stack.")
            debug call ThrowError(recycler[this] != -1, "UniqueStack", "pop", "thistype", this, "Attempted To Pop Invalid Stack.")
            debug call ThrowWarning(first == 0,         "UniqueStack", "pop", "thistype", this, "Popping Empty Stack.")
        
            debug set _first.isNode = false
            
            set _first = _first._next
        endmethod
        
        static if DEBUG_MODE then
            static method calculateMemoryUsage takes nothing returns integer
                local thistype start = 1
                local thistype end = 8191
                local integer count = 0
                
                loop
                    exitwhen integer(start) > integer(end)
                    if (integer(start) + 500 > integer(end)) then
                        return count + checkRegion(start, end)
                    else
                        set count = count + checkRegion(start, start + 500)
                        set start = start + 501
                    endif
                endloop
                
                return count
            endmethod
              
            private static method checkRegion takes thistype start, thistype end returns integer
                local integer count = 0
            
                loop
                    exitwhen integer(start) > integer(end)
                    if (start.isNode) then
                        set count = count + 1
                    endif
                    if (recycler[start] == -1) then
                        set count = count + 1
                    endif
                    set start = start + 1
                endloop
                
                return count
            endmethod
            
            static method getAllocatedMemoryAsString takes nothing returns string
                local thistype start = 1
                local thistype end = 8191
                local string memory = null
                
                loop
                    exitwhen integer(start) > integer(end)
                    if (integer(start) + 500 > integer(end)) then
                        if (memory != null) then
                            set memory = memory + ", "
                        endif
                        set memory = memory + checkRegion2(start, end)
                        set start = end + 1
                    else
                        if (memory != null) then
                            set memory = memory + ", "
                        endif
                        set memory = memory + checkRegion2(start, start + 500)
                        set start = start + 501
                    endif
                endloop
                
                return memory
            endmethod
              
            private static method checkRegion2 takes thistype start, thistype end returns string
                local string memory = null
            
                loop
                    exitwhen integer(start) > integer(end)
                    if (start.isNode) then
                        if (memory == null) then
                            set memory = I2S(start)
                        else
                            set memory = memory + ", " + I2S(start) + "N"
                        endif
                    endif
                    if (recycler[start] == -1) then
                        if (memory == null) then
                            set memory = I2S(start)
                        else
                            set memory = memory + ", " + I2S(start) + "C"
                        endif
                    endif
                    set start = start + 1
                endloop
                
                return memory
            endmethod
        endif
    endmodule
endlibrary