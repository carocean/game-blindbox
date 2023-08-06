//@layout=layout.html

module.exports = (function async(req, res, _, $) {
    // $('div').html('我来了88');
    // $('div').attr('style', 'color:red;');
    _('.container').html($('div').prop('outerHTML'));
    var html = _('html').html();
    res.write(html);
});