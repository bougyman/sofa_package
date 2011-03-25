
function(doc) {
  if(doc.type === "Package" && doc.metadata) {
    emit(parseInt(doc.metadata["votes"]), null);
  }
}
