 $(function () {
    $('#page').show();
    var chart;
    $(document).ready(function() {
        chart = new Highcharts.Chart({
            chart: {
                renderTo: 'container',
                type: 'spline'
            },
            title: {
                text: 'Class averages over time'
            },
            subtitle: {
                text: 'Source: LearnSprout'
            },
            xAxis: {
                type: 'datetime',

                labels: {
                formatter: function() {
                    return '';
                }
            }},
            yAxis: {
                title: {
                    text: 'Grade (%)'
                },
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }],
                min: 0
            },
            tooltip: {
                formatter: function() {
                         return '<b>'+ this.series.name +'</b><br/>'+
                        this.y +'%';
                }
            },

            series: window.series
        });
    });

});