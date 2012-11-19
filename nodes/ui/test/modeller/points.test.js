var chai = require('chai'),
    assert = chai.assert,
    client = require('./client').client;
chai.Assertion.includeStack = true;

describe('Points', function() {

    before(function(done) {
        this.timeout(5000);
        client.initDesign(done);
            
    });

    beforeEach(function(done) {
        this.timeout(5000);
        client.freshDesign(done);

    });

    after(function(done) {
        client.end(done);
    });

    // ---------- Cases ----------

    it('can be created with subsequent mouse clicks', function(done) {
        this.timeout(5000);
        client
            .click('.toolbar .point')
            .moveToWorld(20,10,0)
            .assertCoordinateEqual('.vertex.editing .coordinate', 20, 10, 0)
            .clickOnWorld(20,10,0)
            .isVisible('.vertex.display.point0', function(result) {
                assert.isTrue(result);
                client
                    .clickOnWorld(0,0,0)
                    .clickOnWorld(0,10,0)
                    .clickOnWorld(0,20,0)
                    .click('.toolbar .select')
                    .assertNumberOfDisplayNodes(4, done);
            });
               
    });

    it('can be edited with dragging', function(done) {
        this.timeout(5000);
        client
            .click('.toolbar .point')
            .waitForUrlChange(
                function() { client.clickOnWorld(5,5,0); },
                function() {
                    client
                        .click('.toolbar .select')
                        .moveToWorld(5,5,0)
                        .buttonDown()
                        .moveToWorld(15,15,0)
                        .moveToWorld(15,15,0)
                        .assertCoordinateEqual('.vertex.editing .coordinate', 15, 15, 0)
                        .buttonUp()
                        .assertNumberOfDisplayNodes(1, done);
                });
    });


});
