
function(doc) {
  if(doc.type === "SofaPackage::Package" && doc.metadata) {
    emit(parseInt(doc.metadata["votes"]), null);
  }
}
