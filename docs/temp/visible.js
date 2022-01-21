window.onload = function() {
var ans = "rnon";
var t1="";

for (var i = 1; i < 40; i++) {
 if(document.getElementById("rank"+i) != null) {
 
ans = "rnon";
t1 = document.getElementById("rank"+i+"_rk").innerHTML;

if (t1=="") {
document.getElementById("rank"+i).className=ans;
}
 }
}

};
