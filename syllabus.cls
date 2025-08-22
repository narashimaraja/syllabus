
\def\fileversion{1.0}
\def\filedate{2025/08/05}

%% Starting point of class
\NeedsTeXFormat{LaTeX2e}

\ProvidesClass{syllabus}[\filedate\space Version \fileversion\space]
%%</package>

\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{article}%
}
\ProcessOptions\relax
\LoadClass{article}

% Packages required for table and control making
\RequirePackage{ifthen}
\RequirePackage{longtable}
\RequirePackage{pgffor}
% Helper: Convert to uppercase
\RequirePackage{textcase} % for \MakeTextUppercase
\RequirePackage{array}
\RequirePackage{enumitem}

% -------------------- Page setup ---------------------------
\setlength{\oddsidemargin}{-0.25in}
\setlength{\evensidemargin}{-0.25in}
\setlength{\textwidth}{6in}
\setlength{\topmargin}{-0.25in}
\setlength{\textheight}{9.5in}

% -------------------- Definitions ---------------------------
%% Conditional ifs
\newif\ifprerequisite
\newif\ifpractice
\newif\ifpracticeel
\newif\iflecture
% Defaults:
\prerequisitefalse
\practicefalse
\practiceelfalse
\lecturefalse

%% Counters
\newcounter{latest@course}
\newcounter{numof@courses}
\newcounter{numof@schemes}
\setcounter{numof@schemes}{0}
% Templated
\newcounter{numof@prerequisites}
\newcounter{numof@lectureunits}
\newcounter{numof@practiceunits}
\newcounter{numof@practiceelunits}
\newcounter{numof@coursecos}
\newcounter{temp@counter}

%% Environment
\newwrite\coursefile
\newread\readcoursefile
% \newwrite\writecode

% ------------------------------------------------------------
\newcommand\checkint[1]{%
    \ifnum#1=\numexpr#1\relax
        \typeout{#1 is an integer.}%
        \ifnum#1>3\relax
          \ClassError{syllabus}{#1 is not a valid integer.\MessageBreak}{Use 1 :For Theory; 2 :For Theory+Lab; 3 :For Practical alone.\MessageBreak}%
        \fi
    \else
        \ClassError{syllabus}{#1 is not an integer}{}%
    \fi
}

%% Type definitions
% course type
\def\po{PO}
\def\lo{LO}
\def\lt{LT}
\def\lp{LP}
\def\EL{EL}
\newcommand\checkcoursetype[1]{%
  \edef\coursetypeupper{#1}%
  \ifx\coursetypeupper\po\relax
    \practicetrue
    \lecturefalse
    \def\ltp{{0,0,2}}
    
  \else\ifx\coursetypeupper\lo\relax
    \practicefalse
    \lecturetrue
    \def\ltp{{4,0,0}}
  \else\ifx\coursetypeupper\lt\relax
    \practicefalse
    \lecturetrue
    \def\ltp{{3,1,0}}
  \else\ifx\coursetypeupper\lp\relax
    \practicetrue
    \lecturetrue
    \def\ltp{{3,0,1}}
  \else\ifx\coursetypeupper\EL\relax
    % OK
  \else
    \ClassError{syllabus}{Invalid course type `#1'. Must be PO or LO or LT or LP or EL}{}%
  \fi\fi\fi\fi\fi
}

% practice type
\def\EL{EL}
\newcommand\checkpracticeeltype[1]{%
  \edef\coursetypeupper{#1}%
  % \edef\coursetypeupper{\MakeTextUppercase{#1}}%
  \ifx\coursetypeupper\EL\relax
    \practiceeltrue
    % \def\ltp{{0,0,2}}
    % OK
  \else
    \ClassError{syllabus}{Invalid course type `#1'. Must be PO or LO or LT or LP or EL}{}%
  \fi\fi
}

% course unit type
\newcommand\checkunithour[1]{%
    \ifnum#1=\numexpr#1\relax
        \typeout{#1 is an integer.}%
    \else
        \ClassError{syllabus}{#1 is not an integer}{}%
    \fi
}
% ------------------------------------------------------------

%------------------------------- [if] stmt-------------------------------------
\newif\if@includecourse
\@includecoursefalse
%--------------------------------------------------------------------

\newenvironment{scheme}[1]{%
  % Environment for courses
  \edef\sem{#1}
  \addtocounter{numof@schemes}{1}
  % Defaults
  \setcounter{numof@courses}{0}
  \begingroup
      \newenvironment{definecourse}[1]{%
        \addtocounter{numof@courses}{1}
        \gdef\course@code{##1}
        % Defaults - Move it to course environment
        \practiceelfalse
        \setcounter{numof@lectureunits}{0}
        \setcounter{numof@practiceunits}{0}
        \setcounter{numof@practiceelunits}{0}
        \setcounter{numof@coursecos}{0}
        \def\coursetitle{
            \process@course
          }
        \def\process@course{%
          \ifhmode
            % Remove any skips at the end of the previous paragraph that might cause a blank line, and then end that paragraph:
            \unskip\unskip \par
          \fi
          \@docourse
        }% process@course
      }% End of 1st argument of definecourse environment
      {
        \IfFileExists{\course@code}{
          % Do Nothing
        }{
          \expandafter\immediate\openout\coursefile=\course@code.tex
          % \immediate\openout\writecode=temp.csv
          \immediate\write\coursefile{\string\begin{course}{\arabic{numof@courses}}}
          \immediate\write\coursefile{\space\string\category{}}
          \immediate\write\coursefile{\space\string\commonto{}}
          \immediate\write\coursefile{\space\string\stream{}}
          \immediate\write\coursefile{\space\string\ciemarks{}}
          \immediate\write\coursefile{\space\string\seemarks{}}
          \immediate\write\coursefile{\space\string\seeduration{}}
          \immediate\write\coursefile{\space\string\totalhours{}}
          % \immediate\write\coursefile{ \detokenize{%\string\string\lecture{}
          % }\string use '\lecturecredit{}' to adjust the lecture credit
          % }
          % \immediate\write\coursefile{ \noexpand%\tutorialcredit{}
          % }
          % \immediate\write\coursefile{ % \practicecredit{}}
          \immediate\write\coursefile{\space\string\prerequisites{}}
          \iflecture
            \immediate\write\coursefile{\space\string\begin{units}}
            \immediate\write\coursefile{\space\space\string\unit[4]{sample}}
            \immediate\write\coursefile{\space\string\end{units}}
          \fi
          \ifpractice
            \immediate\write\coursefile{\space\string\begin{practicals}}
            \immediate\write\coursefile{\space\space\string\practicetitle{Hardware experiments}}
            \immediate\write\coursefile{\space\space\string\experiment{Design}}
            \immediate\write\coursefile{\space\space\string\practiceeltitle{Innovative Experiments}}
            \immediate\write\coursefile{\space\space\string\experiment[EL]{For EL experiment}}
            \immediate\write\coursefile{\space\string\end{practicals}}
          \fi
          \immediate\write\coursefile{\string\end{course}}
          % \writecourseheader
          \immediate\closeout\coursefile
        }
      }% End of 2ndargument of definecourse environment
}% End of 1st argument of scheme environment
{% 2nd argument of scheme environment
\endgroup
% Write the final number of courses inside the scheme environment
  \immediate\write\@mainaux
        {\string\gdef\string\thenumof@courses{\arabic{numof@courses}}}%
}% End of 2nd argument of scheme environment

\newcommand{\writecourseheader}{%
  \edef\templine{%
      % \detokenize{\begin{course}}
      %   \expandafter\detokenize{{\arabic{numof@courses}}}
      \detokenize{
          \category{}^^J
          \commonto{}^^J
          \stream{}^^J
          \ciemarks{}^^J
          \seemarks{}^^J
          \seeduration{}^^J
          \totalhours{}^^J
          \@gobble\@percentchar \lecturecredit{}^^J
          \@backslashchar\@percentchar \tutorialcredit{}^^J
          \@percentchar \practicecredit{}^^M
          \prerequisites{}^^J
    }
    \iflecture
      \detokenize{
        % Specify the unit hours within [] and the content of the unit within {}^^J
        % Add \unit[]{} to further add the units of the course^^J
        \begin{units}^^J
          \unit[4]{sample}^^J
        \end{units}^^J
    }\fi
    \ifpractice
      \detokenize{
        % If you want to specify EL component for the experiment, specify `EL` within [] 
        % and the experiment within {}^^J
        % Add \experiment{} (or) \experiment[EL]{} to further add the experiments of the course^^J
        \begin{practicals}^^J
          \practicetitle{Hardware experiments}^^J
          \experiment{Design}^^J
          \practiceeltitle{Innovative Experiments}^^J
          \experiment[EL]{For EL experiment}^^J
        \end{practicals}^^J
    }\fi
    \detokenize{
      \end{course}^^J
    }
  }
  \immediate\write\coursefile{\templine}
}

\newenvironment{course}[1]{%
  \def\courseindex{#1}
  % \xdef\lcredit{\course@\romannumeral\csname courseindex\endcsname @courseltp[1]}
  % \xdef\tcredit{\course@\romannumeral\csname courseindex\endcsname @courseltp[2]}
  % \xdef\pcredit{\course@\romannumeral\csname courseindex\endcsname @courseltp[3]}
  \newcommand*{\numofcos}[1][4]{##1}%
  % \newcommand*{\lecturecredit}[1][\lcredit]{\def\@lcredit{#1}}%
  % \newcommand*{\tutorialcredit}[1][\tcredit]{\def\@tcredit{#1}}%
  % \newcommand*{\practicecredit}[1][\pcredit]{\def\@pcredit{#1}}%
  
  \newcommand*{\category}[1]{\def\@category{##1}}%
  \newcommand*{\@category}{\texttt{\string\category} \texttt{is not set in \corsecode.tex file. Please fix this.}}%
  \newcommand*{\commonto}[1]{\def\@commonto{##1}}%
  \newcommand*{\@commonto}{\texttt{\string\commonto} \texttt{is not set in \corsecode.tex file. Please fix this.}}%
  \newcommand*{\stream}[1]{\def\@stream{##1}}%
  \newcommand*{\@stream}{\texttt{\string\stream} \texttt{is not set in \corsecode.tex file. Please fix this.}}%
  \newcommand*{\ciemarks}[1]{\def\@ciemarks{##1}}%
  \newcommand*{\@ciemarks}{\texttt{\string\ciemarks} \texttt{is not set in \corsecode.tex file. Please fix this.}}%
  \newcommand*{\seemarks}[1]{\def\@seemarks{##1}}%
  \newcommand*{\@seemarks}{\texttt{\string\seemarks} \texttt{is not set in \corsecode.tex file. Please fix this.}}%
  \newcommand*{\seeduration}[1]{\def\@seeduration{##1}}%
  \newcommand*{\@seeduration}{\texttt{\string\seeduration} \texttt{is not set in \corsecode.tex file. Please fix this.}}%
  \newcommand*{\totalhours}[1]{\def\@totalhours{##1}}%
  \newcommand*{\@totalhours}{\texttt{\string\totalhours} \texttt{is not set in \corsecode.tex file. Please fix this.}}%
  \newcommand*{\prerequisites}[1]{
    \def\@temp{#1}
    \def\@spaces{ }
    \ifx\@temp\@empty
      \prerequisitefalse
    \else
      \ifx\@temp\@spaces
        \prerequisitefalse
      \else
        \prerequisitetrue 
        \def\@prerequisites{#1}%
      \fi
    \fi
  }%
  % \begingroup 
    \newenvironment{units}{
      \def\unit{%
        \addtocounter{numof@lectureunits}{1}
         \ifhmode
          % Remove any skips at the end of the previous paragraph that might cause a blank line, and then end that paragraph:
          \unskip\unskip \par
        \fi
        \@dounit
      }
    }% End of 1st arg of units environment
    { }% End of 2nd arg of units environment
    
    \newenvironment{practicals}{
      \def\practicetitle#1{\def\@practicetitle{#1}}%
      \def\practiceeltitle#1{\def\@practiceeltitle{#1}}%
      \def\experiment{%
         \ifhmode
          % Remove any skips at the end of the previous paragraph that might cause a blank line, and then end that paragraph:
          \unskip\unskip \par
        \fi
        \@dopractice%
      }
    }% End of 1st arg of units environment
    { }% End of 2nd arg of units environment
}% End of 1st argument of course environment
{
  % \endgroup
  % \ifx \lcredit \@lcredit
  %   % Do nothing
  % \else
  %   \immediate\write\@mainaux
  %     {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @courseltp[1]{\@lcredit}}%
  % \fi
  % \ifx \tcredit \@tcredit
  %   % Do nothing
  % \else
  %   \immediate\write\@mainaux
  %     {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @courseltp[2]{\@tcredit}}%
  % \fi
  % \ifx \pcredit \@pcredit
  %   % Do nothing
  % \else
  %   \immediate\write\@mainaux
  %     {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @courseltp[3]{\@pcredit}}%
  % \fi
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @category{\@category}}%
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @commonto{\@commonto}}%
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @stream{\@stream}}%
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @ciemarks{\@ciemarks}}%
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @seemarks{\@seemarks}}%
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @seeduration{\@seeduration}}%
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @totalhours{\@totalhours}}%
  \ifprerequisite
    \immediate\write\@mainaux
      {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @prerequisites{\@prerequisites}}%
  \fi% prerequisite
  \ifpractice
    \immediate\write\@mainaux
      {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @practiceeltitle{\@practicetitle}}%
  \fi% practice
  \ifpracticeel
    \immediate\write\@mainaux
      {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @praticeeltitle{\@practiceeltitle}}%
  \fi% practiceel
  %% Total number of lecture units
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @numoflectureunits{\arabic{numof@lectureunits}}}%
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @numofpracticeunits{\arabic{numof@practiceunits}}}%
  \immediate\write\@mainaux
    {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @numofpracticeelunits{\arabic{numof@practiceelunits}}}%
}
%--------------------------------@doitem[def]-----------------------------
\def\@docourse{\@ifnextchar[{\@readpoints}%
                          {\ClassError{syllabus}{Provide Type and Category of the course.\MessageBreak
                          }{%
                            1 must be integer (1 :for Theory alone; 2 :For Theory+Lab; 3 :For Practical alone)\MessageBreak
                            2 must be one of the option(PR :for Professional course, EL :for Elective course)\MessageBreak
                            }
                          }%
}
\def\@dounit{\@ifnextchar[{\@readunits}%
                          {\ClassError{syllabus}{Provide Type and Category of the course.\MessageBreak
                          }{%
                            1 must be integer (1 :for Theory alone; 2 :For Theory+Lab; 3 :For Practical alone)\MessageBreak
                            2 must be one of the option(PR :for Professional course, EL :for Elective course)\MessageBreak
                            }
                          }%
}
\def\@dopractice{\@ifnextchar[{\@readpracticeel}%
                          {\@readpractice}%
}
%-------------------------------@readpoints[#1]---------------------------
\def\@readpoints[#1]#2{% #2: define course title
  \def\@type{#1}% PO, LO, LP, LT
  \checkcoursetype{\@type}
  
  \if@filesw
    % Store all Data
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\value{numof@courses}@coursesem{\sem}}%
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\value{numof@courses}@coursecode{\course@code}}%
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\value{numof@courses}@coursetype{#1}}%
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\value{numof@courses}@coursetitle{#2}}%
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\value{numof@courses}@courseltp{\ltp}}%
    % \immediate\write\@mainaux
    %     {\string\gdef\string\course@\romannumeral\value{numof@courses}@courseindex{\value{numof@courses}}}%
  \fi
}% @readpoints

\def\@readunits[#1]#2{%
  \def\@type{#1}
  \checkunithour{\@type}
  \if@filesw
    % Store all Data
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @lectureunit@\roman{numof@lectureunits}@hour{#1}}%
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @lectureunit@\roman{numof@lectureunits}@content{\detokenize{#2}}}%
        % \expandafter\edef\temp{\csname courseof@\romannumeral\csname courseindex\endcsname @lectureunit@\roman{numof@lectureunits}@content\endcsname}
        % \typeout{The content of lecture unit: \temp}
        % \typeout{The content of lecture unit: \space {\csname courseof@\romannumeral\courseindex @lectureunit@\roman{numof@lectureunits}@content\endcsname}}%{\arabic{numof@lectureunits}}}
        % \typeout{The content of lecture unit: \space \csname courseof@\romannumeral\courseindex @lectureunit@\roman{numof@lectureunits}@content\endcsname}%{\arabic{numof@lectureunits}}}
        % \typeout{The content of lecture unit: \space \expandafter\detokenize\expandafter{\courseof@\romannumeral\courseindex @lectureunit@\arabic{numof@lectureunits}@content}}%{\arabic{numof@lectureunits}}}
  \fi
}% @readunits

\def\@readpracticeel[#1]#2{%
  \def\@type{#1}
  % \def\@category{#2}
  % \checkpracticeeltype{\@type}
  \addtocounter{numof@practiceelunits}{1}
  \if@filesw
    % Store all Data
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @practiceelunitcontent@\roman{numof@practiceelunits}{#2}}%
  \fi
}% @readpracticeel

\def\@readpractice#1{%
  \addtocounter{numof@practiceunits}{1}
  \if@filesw
    % Store all Data
    \immediate\write\@mainaux
        {\string\gdef\string\course@\romannumeral\csname courseindex\endcsname @practiceunitcontent@\roman{numof@practiceunits}{#1}}%
  \fi
}% @readpractice

%----------------Template commands------------------------------
\long\def\xloop #1\repeat{#1\else\expandafter\@gobbletwo\fi\xloopa{#1}}
\long\def\xloopa #1{#1\else\expandafter\@gobbletwo\fi\xloopa{#1}}
\def\cidx{1}
% \courseunitrow
\newcommand{\xpandtable}[5]{%
  \begingroup
  \def\scartchtable##1{%
    % \iflecture
    % {%
      \unexpanded{%
        \begin{tabular}{p{\dimexpr0.8\textwidth-2\tabcolsep-1.8\arrayrulewidth\relax}|%
                        >{\raggedleft\arraybackslash}p{\dimexpr0.2\textwidth-2\tabcolsep-1.2\arrayrulewidth\relax}%
                      }%
        \textbf
      }%
      {\unexpanded{Unit - \MakeTextUppercase}{\romannumeral##1}}%
      \unexpanded{%
        &%
        \textbf
      }{%
        \unexpanded{\expandafter{\csname course@\romannumeral#5@lectureunit@\romannumeral##1@hour\endcsname}}%
      }
      \unexpanded{%
        \\%
        \hline
        \multicolumn{2}{p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}}%
      }{%
        \unexpanded{\expandafter{\csname course@\romannumeral#5@lectureunit@\romannumeral##1@content\endcsname}}
      }%
      \unexpanded{%
      \\%
      \hline
        \end{tabular}%
        \\%
      }%
      % \CsNameToCsToken{@\ifnum\numoflectureunits=#1 gobble\else firstofone\fi}{\noexpand\hline}%
      % \unexpanded{\ifnum\expandafter{\csname course@\romannumeral\csname #5\endcsname @numoflectureunits\endcsname}=#1 \expandafter\@gobble\else\expandafter\@firstofone\fi}{\noexpand\hline}%
      % \unexpanded{\ifnum2=##1\expandafter\@gobble\else\expandafter\@firstofone\fi}{\noexpand\hline}%
    % }%
    % \fi
    % \ifpractice
    % {%
    %   \unexpanded{%
    %     \item \expandafter{\csname course@\romannumeral\csname #5\endcsname @practiceunitcontent@\romannumeral\csname #1\endcsname\endcsname}%
    %   }%
    %   \unexpanded{\ifnum#3=#1\expandafter\@gobble\else\expandafter\@firstofone\fi}%
    %     {%
    %      % Do Nothing % 
    %     }%
    % }%
    % \fi
    % \ifpracticeel
    % {%
    %   \unexpanded{%
    %     \item \expandafter{\csname course@\romannumeral\csname #5\endcsname @practiceelunitcontent@\romannumeral\csname #1\endcsname\endcsname}%
    %   }%
    %   \unexpanded{\ifnum#4=#1\expandafter\@gobble\else\expandafter\@firstofone\fi}%
    %     {%
    %      % Do Nothing % 
    %     }%
    % }%
    % \fi
  }% End of scartctable
  \expanded{% 
    \endgroup
    % #3%
    % {%
      \unexpanded{%
        \begin{longtable}{|@{}c@{}|}%
        \hline
        \endfirsthead
        \hline
        \endhead
        \hline
        \endfoot
        \hline
        \endlastfoot
      }%
      \unexpanded{%
        \begin{tabular}{p{\dimexpr\textwidth\relax}}%
          \hline%
          % \\%
          \textbf
      }%
      {\unexpanded{Semester - \expandafter{\printsemester}}}%%check for \expandafter
      \unexpanded{%
        \\%
        \hline%
        \textbf
      }%
      {\unexpanded\expandafter{\printcoursetitle}}
      \unexpanded{%
        \\%
        \textbf
      }%
      {\unexpanded\expandafter{\printcoursecategory}}
      \unexpanded{%
        \\%
        \textbf
      }%
      {\unexpanded\expandafter{\printcoursestream}}
      \unexpanded{%
        \\%
        \end{tabular}%
        \\%
      }%
      \unexpanded{%
        \begin{tabular}{p{\dimexpr0.2\textwidth-\tabcolsep-0.4\arrayrulewidth\relax}|%
                        p{\dimexpr0.2\textwidth-\tabcolsep-0.4\arrayrulewidth\relax}|%
                        p{\dimexpr0.2\textwidth-\tabcolsep-0.4\arrayrulewidth\relax}|%
                        p{\dimexpr0.2\textwidth-\tabcolsep-0.4\arrayrulewidth\relax}|%
                        p{\dimexpr0.2\textwidth-\tabcolsep-0.4\arrayrulewidth\relax}}%
      \hline%
      \textbf{Course Code}&\textbf{:}\space\printcoursecode & & \textbf{CIE} & \textbf{:}\space\printciemarks\space Marks\\%
      \textbf{Credit\space L:T:P}&\textbf{:}\space\printcourseltp & & \textbf{SEE} & \textbf{:}\space\printseemarks\space Marks\\%
      \textbf{Total Hours}&\textbf{:}\space\printcoursehours & & \textbf{SEE Duration} & \textbf{:}\space\printseehours\space Hours\\%
      \hline%
      }
      \unexpanded{%
        \end{tabular}%
        \\
      }%
    % }%3#
    % \iflecture
      % \expandafter\innerloop
      % \expandafter{\number\numexpr(1)\expandafter\relax\expandafter}%
      % \expandafter{\number\numexpr(#2)\relax}%
    % \fi
    % \ifpractice
    %     \unexpanded{%
    %       \begin{tabular}{>{\raggedleft\arraybackslash}p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}}
    %       \textbf
    %     }%
    %     {\unexpanded{\expandafter{\csname course@\romannumeral\csname x\endcsname @practicetitle\endcsname}}}
    %     \unexpanded{%
    %       \\%
    %     }
      \expandafter\innloop
      \expandafter{\number\numexpr(1)\expandafter\relax\expandafter}%
      \expandafter{\number\numexpr(#1)\relax}%
      % \unexpanded{
      %     \end{tabular}%
      %     \\%
      % }
    % \fi
    % \ifpracticeel
    %     \unexpanded{%
    %       \begin{tabular}{>{\raggedleft\arraybackslash}p{\dimexpr\textwidth-2\tabcolsep-2\arrayrulewidth\relax}}
    %       \textbf
    %     }%
    %     {\unexpanded{\expandafter{\csname course@\romannumeral\csname x\endcsname @practicetitle\endcsname}}}
    %     \unexpanded{%
    %       \\%
    %     }%
      % \expandafter\innloop
      % \expandafter{\number\numexpr(1)\expandafter\relax\expandafter}%
      % \expandafter{\number\numexpr(#4)\relax}%
    %   \unexpanded{
    %       \end{tabular}%
    %       \\%
    %   }%
    % \fi
    %#5%
    
    \unexpanded{
      \end{longtable}%
    }
  }%
}

\newcommand\innloop[2]{%
  \ifnum#1>#2 \expandafter\@gobble\else\expandafter\@firstofone\fi
  {%
    \scartchtable{#1}%
    \expandafter\innloop\expandafter{\number\numexpr#1+1}{#2}%
  }%
}%
%----------------AtEndDocument------------------------------
\AtEndDocument{%
% \closein\coursefile
  \foreach \x in {1,...,\arabic{numof@courses}}{%
  % \course@\romannumeral\value{numof@courses}@coursecode
    \edef\course@code{\csname course@\romannumeral\csname x\endcsname @coursecode\endcsname}
    \edef\printcoursecode{\MakeTextUppercase{\csname course@\romannumeral\csname x\endcsname @coursecode\endcsname}}
    \edef\printsemester{\MakeTextUppercase{\romannumeral\csname course@\romannumeral\csname x\endcsname @coursesem\endcsname}}
    \edef\printcoursetitle{\csname course@\romannumeral\csname x\endcsname @coursetitle\endcsname}
    \edef\printcoursecategory{\csname course@\romannumeral\csname x\endcsname @category\endcsname}
    \edef\printcoursestream{\csname course@\romannumeral\csname x\endcsname @stream\endcsname}
    \edef\printcourseltp{\csname course@\romannumeral\csname x\endcsname @courseltp\endcsname}
    \edef\printciemarks{\csname course@\romannumeral\csname x\endcsname @ciemarks\endcsname}
    \edef\printseemarks{\csname course@\romannumeral\csname x\endcsname @cseemarks\endcsname}
    \edef\printcoursehours{\csname course@\romannumeral\csname x\endcsname @totalhours\endcsname}
    \edef\printseehours{\csname course@\romannumeral\csname x\endcsname @seeduration\endcsname}

    % read the remaining definitions from \coursecode.tex file
    \input{\course@code.tex}
    \edef\thenumof@lectureunits{\csname course@\romannumeral\csname x\endcsname @numoflectureunits\endcsname}
    \edef\thenumof@practiceunits{\csname course@\romannumeral\csname x\endcsname @numofpracticeunits\endcsname}
    \edef\thenumof@practiceelunits{\csname course@\romannumeral\csname x\endcsname @numofpracticeelunits\endcsname}
    % unwind the contents
    \ifnum \thenumof@lectureunits > 0\relax
      \foreach \y in {1,...,\thenumof@lectureunits}{%
        \immediate\write\@mainaux
          {\string\gdef\string\printhoursoflectureunit@\romannumeral\csname y\endcsname{\csname course@\romannumeral\csname x\endcsname @lectureunit@\romannumeral\csname y\endcsname @hour\endcsname}}%
        \immediate\write\@mainaux
          {\string\gdef\string\printcontentoflectureunit@\romannumeral\csname y\endcsname{\csname course@\romannumeral\csname x\endcsname @lectureunit@\romannumeral\csname y\endcsname @content\endcsname}}%
      }
    \fi
    \ifnum \thenumof@practiceunits > 0\relax
      \edef\printpracticetitle{\csname course@\romannumeral\csname x\endcsname @practicetitle\endcsname}
      \foreach \y in {1,...,\thenumof@practiceunits}{%
        \immediate\write\@mainaux
          {\string\gdef\string\printcontentof@practiceunit@\romannumeral\csname y\endcsname{\csname course@\romannumeral\csname x\endcsname @practiceunitcontent@\romannumeral\csname y\endcsname\endcsname}}%
      }
    \fi
    \ifnum \thenumof@practiceelunits > 0\relax
      \edef\printpracticeeltitle{\course@\romannumeral\csname x\endcsname @practiceeltitle}
      \foreach \y in {1,...,\thenumof@practiceunits}{%
        \immediate\write\@mainaux
          {\string\gdef\string\printcontentof@practiceleunit@\romannumeral\csname y\endcsname{\csname course@\romannumeral\csname x\endcsname @practiceelunitcontent@\romannumeral\csname y\endcsname\endcsname}}%
      }
    \fi
    \clearpage% Forces a page break.
    \input{temp.tex}
  }
}% AtEndDocument

\endinput
