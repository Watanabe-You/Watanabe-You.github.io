window.onload = function() {
var ans = "rnon";

for (var i = 1; i < 40; i++) {
 if(document.getElementById("rank"+i) != null) {
 
ans = "rnon";
rk1 = document.getElementById("rank"+i+"_rk").innerHTML;
if (rk1=="") {
document.getElementById("rank"+i).className="non";
document.getElementById("rank"+i+"_b").className="non";
}
else {  
bf1 = document.getElementById("rank"+i+"_bf").innerHTML;

if (bf1=="-") {
ans = "rnew";
}
else {

 if (Number(rk1)>Number(bf1)){
 ans = "rdown";
 }
 else if (Number(rk1)<Number(bf1)){
 ans = "rup";
  if (Number(rk1)+5<Number(bf1)){
  ans = "rnew";
  }
 }
}
document.getElementById("rank"+i+"_updown").className=ans;
}

 }
}

};
