
var FITEMS = arr_flatten(TITEMS);

function arr_flatten (x) {
   var y = []; if (x == null) return y;
   for (var i=0; i<x.length; i++) {
      if (typeof(x[i]) == "object") {
         var flat = arr_flatten(x[i]);
         for (var j=0; j<flat.length; j++)
             y[y.length]=flat[j];
      } else {
         if ((i%3==0))
          y[y.length]=x[i+1];
      }
   }
   return y;
}

