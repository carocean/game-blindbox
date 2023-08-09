//@layout=layout.html

module.exports = (async function (req, res, _, $) {
    _('.container').html($('.blindbox').prop('outerHTML'));
    var html = _('html').html();
    res.write(html);
});