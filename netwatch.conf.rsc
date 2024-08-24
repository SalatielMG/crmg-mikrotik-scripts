:global ispUp;
:set $ispUp "ISP1";
:log info "Up Telmex - $ispUp";
/system script run onUpISPScript;
:global ispDown;
:set $ispDown "ISP1";
:log info "Down Telmex - $ispDown";
/system script run onDownISPScript;


:global ispUp;
:set $ispUp "ISP2";
:log info "Up Mega 1 - $ispUp";
/system script run onUpISPScript;
:global ispDown;
:set $ispDown "ISP2";
:log info "Down Mega 1 - $ispDown";
/system script run onDownISPScript;


:global ispUp;
:set $ispUp "ISP3";
:log info "Up Mega 2 - $ispUp";
/system script run onUpISPScript;
:global ispDown;
:set $ispDown "ISP3";
:log info "Down Mega 2 - $ispDown";
/system script run onDownISPScript;

