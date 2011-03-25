
function(doc) {
  if(doc.type === "SofaPackage::Package" && doc.votes) {
    emit(parseInt(doc.votes), null);
  }
}
