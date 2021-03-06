library NxList /* v1.0.0.2
************************************************************************************
*
*   */uses/*
*   
*       */ ErrorMessage /*         hiveworkshop.com/forums/submissions-414/snippet-error-message-239210/
*
************************************************************************************
*
*   module NxList
*
*       Description
*       -------------------------
*
*           NA
*
*       Fields
*       -------------------------
*
*           readonly static integer sentinel
*
*           readonly thistype list
*
*           readonly thistype first
*           readonly thistype last
*
*           readonly thistype next
*           readonly thistype prev
*
*       Methods
*       -------------------------
*
*           method destroy takes nothing returns nothing
*               - May only destroy lists
*
*           method push takes nothing returns thistype
*           method enqueue takes nothing returns thistype
*
*           method pop takes nothing returns nothing
*           method dequeue takes nothing returns nothing
*
*           method remove takes nothing returns nothing
*
*           method clear takes nothing returns nothing
*               -   Initializes list, use instead of create
*
*           debug static method calculateMemoryUsage takes nothing returns integer
*           debug static method getAllocatedMemoryAsString takes nothing returns string
*
************************************************************************************/
    module NxList
        private static thistype nodeCount = 0
        debug private boolean isNode
        debug private boolean isCollection
        
        private thistype _list
        method operator list takes nothing returns thistype
            debug call ThrowError(this == 0,    "NxList", "list", "thistype", this, "Attempted To Read Null Node.")
            debug call ThrowError(not isNode,   "NxList", "list", "thistype", this, "Attempted To Read Invalid Node.")
            return _list
        endmethod
        
        private thistype _next
        method operator next takes nothing returns thistype
            debug call ThrowError(this == 0,    "NxList", "next", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,   "NxList", "next", "thistype", this, "Attempted To Read Invalid Node.")
            return _next
        endmethod
        
        private thistype _prev
        method operator prev takes nothing returns thistype
            debug call ThrowError(this == 0,    "NxList", "prev", "thistype", this, "Attempted To Go Out Of Bounds.")
            debug call ThrowError(not isNode,   "NxList", "prev", "thistype", this, "Attempted To Read Invalid Node.")
            return _prev
        endmethod
        
        private thistype _first
        method operator first takes nothing returns thistype
            debug call ThrowError(this == 0,        "NxList", "first", "thistype", this, "Attempted To Read Null List.")
            debug call ThrowError(not isCollection, "NxList", "first", "thistype", this, "Attempted To Read Invalid List.")
            return _first
        endmethod
        
        private thistype _last
        method operator last takes nothing returns thistype
            debug call ThrowError(this == 0,        "NxList", "last", "thistype", this, "Attempted To Read Null List.")
            debug call ThrowError(not isCollection, "NxList", "last", "thistype", this, "Attempted To Read Invalid List.")
            return _last
        endmethod
        
        static method operator sentinel takes nothing returns integer
            return 0
        endmethod
        
        private static method allocateNode takes nothing returns thistype
            local thistype this = thistype(0)._next
            
            if (0 == this) then
                debug call ThrowError(nodeCount == 8191, "NxList", "allocateNode", "thistype", 0, "Overflow.")
                
                set this = nodeCount + 1
                set nodeCount = this
            else
                set thistype(0)._next = _next
            endif
            
            return this
        endmethod
        
        method push takes nothing returns thistype
            local thistype node = allocateNode()
            
            debug call ThrowError(this == 0,        "NxList", "push", "thistype", this, "Attempted To Push On To Null List.")
            debug call ThrowError(not isCollection, "NxList", "push", "thistype", this, "Attempted To Push On To Invalid List.")
            
            debug set node.isNode = true
            
            set node._list = this
        
            if (_first == 0) then
                set _first = node
                set _last = node
                set node._next = 0
            else
                set _first._prev = node
                set node._next = _first
                set _first = node
            endif
            
            set node._prev = 0
            
            return node
        endmethod
        method enqueue takes nothing returns thistype
            local thistype node = allocateNode()
            
            debug call ThrowError(this == 0,        "NxList", "enqueue", "thistype", this, "Attempted To Enqueue On To Null List.")
            debug call ThrowError(not isCollection, "NxList", "enqueue", "thistype", this, "Attempted To Enqueue On To Invalid List.")
            
            debug set node.isNode = true
            
            set node._list = this
        
            if (_first == 0) then
                set _first = node
                set _last = node
                set node._prev = 0
            else
                set _last._next = node
                set node._prev = _last
                set _last = node
            endif
            
            set node._next = 0
            
            return node
        endmethod
        method pop takes nothing returns nothing
            local thistype node = _first
            
            debug call ThrowError(this == 0,        "NxList", "pop", "thistype", this, "Attempted To Pop Null List.")
            debug call ThrowError(not isCollection, "NxList", "pop", "thistype", this, "Attempted To Pop Invalid List.")
            debug call ThrowError(node == 0,        "NxList", "pop", "thistype", this, "Attempted To Pop Empty List.")
            
            debug set node.isNode = false
            
            set _first._list = 0
            
            set _first = _first._next
            if (_first == 0) then
                set _last = 0
            else
                set _first._prev = 0
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        method dequeue takes nothing returns nothing
            local thistype node = _last
            
            debug call ThrowError(this == 0,        "NxList", "dequeue", "thistype", this, "Attempted To Dequeue Null List.")
            debug call ThrowError(not isCollection, "NxList", "dequeue", "thistype", this, "Attempted To Dequeue Invalid List.")
            debug call ThrowError(node == 0,        "NxList", "dequeue", "thistype", this, "Attempted To Dequeue Empty List.")
            
            debug set node.isNode = false
            
            set _last._list = 0
        
            set _last = _last._prev
            if (_last == 0) then
                set _first = 0
            else
                set _last._next = 0
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        method remove takes nothing returns nothing
            local thistype node = this
            set this = node._list
            
            debug call ThrowError(node == 0,        "NxList", "remove", "thistype", this, "Attempted To Remove Null Node.")
            debug call ThrowError(not node.isNode,  "NxList", "remove", "thistype", this, "Attempted To Remove Invalid Node (" + I2S(node) + ").")
            
            debug set node.isNode = false
            
            set node._list = 0
        
            if (0 == node._prev) then
                set _first = node._next
            else
                set node._prev._next = node._next
            endif
            if (0 == node._next) then
                set _last = node._prev
            else
                set node._next._prev = node._prev
            endif
            
            set node._next = thistype(0)._next
            set thistype(0)._next = node
        endmethod
        method clear takes nothing returns nothing
            debug local thistype node = _first
        
            debug call ThrowError(this == 0,            "NxList", "clear", "thistype", this, "Attempted To Clear Null List.")
            
            debug if (not isCollection) then
                debug set isCollection = true
                
                debug set _first = 0
                debug set _last = 0
                
                debug return
            debug endif
            
            static if DEBUG_MODE then
                loop
                    exitwhen node == 0
                    set node.isNode = false
                    set node = node._next
                endloop
            endif
            
            if (_first == 0) then
                return
            endif
            
            set _last._next = thistype(0)._next
            set thistype(0)._next = _first
            
            set _first = 0
            set _last = 0
        endmethod
        method destroy takes nothing returns nothing
            debug call ThrowError(this == 0,            "NxList", "destroy", "thistype", this, "Attempted To Destroy Null List.")
            debug call ThrowError(not isCollection,     "NxList", "destroy", "thistype", this, "Attempted To Destroy Invalid List.")
            
            call clear()
            
            debug set isCollection = false
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
                    if (start.isCollection) then
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
                    if (start.isCollection) then
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