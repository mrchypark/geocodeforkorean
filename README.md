# geocodeforkorean

getwd()로 확인한 작업공간에 geocodeforkorean.R파일을 저장합니다.<br>
R 콘솔에 source("geocodeforkorean.R",encoding="UTF-8")을 입력하면 시작합니다.<br>
처음에 인풋데이터의 경로와 아웃풋데이터를 저장할 경로를 물어보면 예시한 양식으로 입력합니다.<br>
input 폴더에 인풋 파일 예시가 있습니다. 양식에 따라 주세요.<br>
output 은 xls 파일로 no, adress, lon, lat 컬럼으로 저장됩니다.<br>
jdk를 설치 하셔야 작동합니다.<br>
<br>
<br>
<br>
v0.1<br>
* 겹치는 주소에 대해서 한번만 요청한 후 다시 합쳐서 결과물을 저장합니다.
* 즉 주소를 여러번 동시에 넣어도 괜찮습니다.(느려지는 건...)
* 입력 파일은 꼭 test.csv와 같은 양식을 따라주어야 하며 csv 파일 양식으로 저장하셔야만 합니다.
* 결과 파일은 아웃풋 폴더에 result_인풋파일이름.xls 로 저장됩니다. (네 엑셀로 저장됩니다.)
* 엑셀로 저장 때문에 jdk를 컴퓨터에 설치하셔야 합니다.

