clc
warning off
clear all

%% Instructions

% Use this template script to generate a bus hierarchy
% Definition of the hierarchy is as follows

% 1.....prefix: The prefix is the string that will be applied to the bus type
%               name at every defined level
% 2.... levels: This is a recursive cell structure that lets you define the 
%               hierachy you desire. The cell numbering ( {a,b} ) for each
%               level follows a few basic rules for proper hierarchy
%               assignemnt
                    
%               Rule 1: If the cell is the last entry in the line, then the
%               first index (a) should always be 1. The second index (b) is
%               the number of the element at the level you are defining. 
%               
%               Example:    levels{1,1} = {'Name_1'}
%                                  ^^^ last cell
%                           levels{1,1}{1,2} = {'Name_2'}
%                                       ^^^ last cell
%               
%               Rule 2: If the cell is not last entry in the line, then the
%               first index (a) should be a 2, which indicates it is a
%               child of another node. This continues for all cells that
%               meet Rule 2, until you are defining a cell that meets Rule
%               1. The second index (b) should match the second index of the
%               parent node for all nodes that meets Rule 2.
%
%               Examples:   levels{1,1}={'TOP_1'}; 
%                           levels{2,1}{1,1} ={'COMPO_1'};
%                                  ^ Child node of "TOP_1"
%                           levels{2,1}{2,1}{1,1} ={'COMPO_1_1'};
%                                       ^ Child node of "COMPO_1"

%                           levels{2,1}{1,2} ={'COMPO_2'};
%                           levels{2,1}{2,2}{1,1} ={'COMPO_2_1'};
%               Child node of "COMPO_2" ^,^ "COMPO_2" is 2nd at this level
%                                         
% 3.... children:   This is another cell structure, similar to levels, that
%                   defines what bus elements will be added to >every< level
%                   that was defined in the "levels" variable. For example,
%                   if you define only bus to be a "child", then every node
%                   in the "levels" hierarchy will contain that one "child"
%                   bus. Note that the children function can contain as
%                   much depth as desired, just like the levels variable,
%                   but is recursive at every node - so use cautiously

% Prefix string definition
%-------------------------
prefix='PREFIX';

%Definition of bus level names
%-----------------------------

%Example top level 1 & below
levels{1,1}={'TOP_1'};
levels{2,1}{1,1} ={'COMPO_1'};
levels{2,1}{2,1}{1,2} ={'COMPO_1_2'};
levels{2,1}{1,2} ={'COMPO_2'};
levels{2,1}{2,2}{1,1} ={'COMPO_2_1'};
levels{2,1}{2,2}{2,1}{1,1} ={'COMPO_2_1_1'};
levels{2,1}{2,2}{2,1}{1,2} ={'COMPO_2_1_2'};
levels{2,1}{2,2}{1,2} ={'COMPO_2_2'};
levels{2,1}{1,3} ={'COMPO_3'};

%Example top level 2 & below
levels{1,2}={'TOP_2'};
levels{2,2}{1,1} ={'COMPO_1'};

% Child busses to be created at every level
%-------------------------------------------
children{1,1}={'CHILD_1'};
children{1,2}={'CHILD_2'};
children{2,2}={'CHILD_2_1','CHILD_2_2','CHILD_2_3'};

%% DO NOT MODIFY BELOW THIS LINE %%
%---------------------------------%
fprintf('<<!>> Creating bus objects...\n')
for i=1:size(levels,2)
    createBusHierarchy(prefix,levels(:,i),children)
end

%Launch bus editor
try
    fprintf('<<!>> Opening Bus Editor...\n')
    open(sprintf('%s_%s_t',prefix,levels{1,1}{1}))
end

ws_vars=whos;
for i=1:length(ws_vars)
    if ~strcmp(ws_vars(i).class,'Simulink.Bus')
        eval(sprintf('clear %s',ws_vars(i).name))
    end
end

%cleanup
clear i ws_vars



warning on
fprintf('<<!>> Done!\n')
