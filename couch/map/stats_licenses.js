
function(doc) {
  if(typeof(doc.license) === "string"){
    emit(doc.license, 1)
  } else {
    for(i in doc.license){
      emit(doc.license[i], 1);
    }
  }
}
