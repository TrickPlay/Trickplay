package com.trickplay.gameservice.dao;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import com.trickplay.gameservice.domain.User;

//@RunWith(SpringJUnit4ClassRunner.class)
//@ContextConfiguration(locations = { "classpath:/applicationConfig.xml" })
public class UserDaoTest {

    private JdbcTemplate jdbcTemplate;
    private UserDAO userDao;

    @Autowired
    public void setJdbcTemplate(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        System.out.println("i am here");
        jdbcTemplate
                .execute("insert into user (id, username, password, email) values (1, 'u1', 'test', 'u1@tp.com')");
        jdbcTemplate
                .execute("insert into user (id, username, password, email) values (2, 'u2', 'test', 'u2@tp.com')");
        jdbcTemplate
                .execute("insert into user (id, username, password, email) values (3, 'u3', 'test', 'u3@tp.com')");
    }

    @Autowired
    public void setUserDao(UserDAO userDao) {
        this.userDao = userDao;
    }

    @Test
    public void testFindByIdUserExists() {
        User user = userDao.findById(1L, false);
        assertNotNull(user);
        assertEquals("u1", user.getUsername());
    }
    /*
     * public void testFindByIdWhereRestaurantExists() { Restaurant restaurant =
     * restaurantDao.findById(1); assertNotNull(restaurant);
     * assertEquals("Burger Barn", restaurant.getName()); }
     * 
     * public void testFindByIdWhereRestaurantDoesNotExist() { Restaurant
     * restaurant = restaurantDao.findById(99); assertNull(restaurant); }
     * 
     * public void testFindByNameWhereRestaurantExists() { List<Restaurant>
     * restaurants = restaurantDao.findByName("Veggie Village"); assertEquals(1,
     * restaurants.size()); Restaurant restaurant = restaurants.get(0);
     * assertEquals("Veggie Village", restaurant.getName());
     * assertEquals("Main Street", restaurant.getAddress().getStreetName());
     * assertEquals(2, restaurant.getEntrees().size()); }
     * 
     * public void testFindByNameWhereRestaurantDoesNotExist() {
     * List<Restaurant> restaurants =
     * restaurantDao.findByName("No Such Restaurant"); assertEquals(0,
     * restaurants.size()); }
     * 
     * public void testFindByStreetName() { List<Restaurant> restaurants =
     * restaurantDao.findByStreetName("Main Street"); assertEquals(2,
     * restaurants.size()); Restaurant r1 =
     * restaurantDao.findByName("Burger Barn").get(0); Restaurant r2 =
     * restaurantDao.findByName("Veggie Village").get(0);
     * assertTrue(restaurants.contains(r1));
     * assertTrue(restaurants.contains(r2)); }
     * 
     * public void testFindByEntreeNameLike() { List<Restaurant> restaurants =
     * restaurantDao.findByEntreeNameLike("%burger"); assertEquals(2,
     * restaurants.size()); }
     * 
     * public void testFindRestaurantsWithVegetarianOptions() { List<Restaurant>
     * restaurants = restaurantDao.findRestaurantsWithVegetarianEntrees();
     * assertEquals(2, restaurants.size()); }
     * 
     * public void testModifyRestaurant() { String oldName = "Burger Barn";
     * String newName = "Hamburger Hut"; Restaurant restaurant =
     * restaurantDao.findByName(oldName).get(0); restaurant.setName(newName);
     * restaurantDao.update(restaurant); List<Restaurant> results =
     * restaurantDao.findByName(oldName); assertEquals(0, results.size());
     * results = restaurantDao.findByName(newName); assertEquals(1,
     * results.size()); }
     * 
     * public void testDeleteRestaurantAlsoDeletesAddress() { String
     * restaurantName = "Dover Diner"; int preRestaurantCount =
     * jdbcTemplate.queryForInt("select count(*) from restaurant"); int
     * preAddressCount = jdbcTemplate.queryForInt(
     * "select count(*) from address where street_name = 'Dover Street'");
     * Restaurant restaurant = restaurantDao.findByName(restaurantName).get(0);
     * restaurantDao.delete(restaurant); List<Restaurant> results =
     * restaurantDao.findByName(restaurantName); assertEquals(0,
     * results.size()); int postRestaurantCount =
     * jdbcTemplate.queryForInt("select count(*) from restaurant");
     * assertEquals(preRestaurantCount - 1, postRestaurantCount); int
     * postAddressCount = jdbcTemplate.queryForInt(
     * "select count(*) from address where street_name = 'Dover Street'");
     * assertEquals(preAddressCount - 1, postAddressCount); }
     * 
     * public void testDeleteRestaurantDoesNotDeleteEntrees() { String
     * restaurantName = "Dover Diner"; int preRestaurantCount =
     * jdbcTemplate.queryForInt("select count(*) from restaurant"); int
     * preEntreeCount = jdbcTemplate.queryForInt("select count(*) from entree");
     * Restaurant restaurant = restaurantDao.findByName(restaurantName).get(0);
     * restaurantDao.delete(restaurant); List<Restaurant> results =
     * restaurantDao.findByName(restaurantName); assertEquals(0,
     * results.size()); int postRestaurantCount =
     * jdbcTemplate.queryForInt("select count(*) from restaurant");
     * assertEquals(preRestaurantCount - 1, postRestaurantCount); int
     * postEntreeCount =
     * jdbcTemplate.queryForInt("select count(*) from entree");
     * assertEquals(preEntreeCount, postEntreeCount); } }
     */
}
